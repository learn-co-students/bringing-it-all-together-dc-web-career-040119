class Dog
  attr_accessor :id, :name, :breed

  def initialize(id: id, name: name, breed: breed)
    @id = id
    @name = name
    @breed = breed
  end

  def save
    if id
      update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, name, breed)
      self.id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
      self
    end
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, name, breed, id)
  end

  # Class Methods

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute('DROP TABLE IF EXISTS dogs')
  end

  def self.create(attributes)
    Dog.new(attributes).save
  end

  def self.new_from_db(attributes)
    Dog.new(id: attributes[0], name: attributes[1], breed: attributes[2])
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"

    row = DB[:conn].execute(sql, id)[0]

    Dog.new_from_db(row)
  end

  def self.find_or_create_by(attributes)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?
    SQL

    row = DB[:conn].execute(sql, attributes[:name], attributes[:breed])[0]

    row.nil? ? create(attributes) : Dog.new_from_db(row)
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    row = DB[:conn].execute(sql, name)[0]
    Dog.new_from_db(row)
  end
end
