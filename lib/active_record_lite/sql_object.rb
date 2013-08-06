require_relative './associatable'
require_relative './db_connection'
require_relative './mass_object'
require_relative './searchable'
require 'active_support/inflector'

class SQLObject < MassObject
  extend Associatable
  extend Searchable


  def self.set_table_name(table_name)
    @table_name = table_name.underscore
  end

  def self.table_name
    @table_name
  end

  def self.all
    result = DBConnection.execute(<<-SQL)
      SELECT * FROM #{table_name}
    SQL

    parse_all(result)
  end

  def self.find(id)
    query = "SELECT * FROM #{table_name} WHERE id=?"
    result = DBConnection.execute(query, id)

    parse_all(result).first
  end


  def save
    self.id.nil? ? create : update
  end

  def attribute_values
    values = []
    self.class.attributes.each do |attr|
      values << self.send(attr)
    end
    values
  end

  private
  def create
    attr_names = self.class.attributes.join(", ")
    q_marks = (['?'] * self.class.attributes.count).join(", ")
    query =
      "INSERT INTO #{self.class.table_name}
       (#{attr_names})
       VALUES (#{q_marks})"
    values = self.attribute_values
    DBConnection.execute(query, *values)
    self.id = DBConnection.last_insert_row_id + 1
    p "succesfully inserted!"
  end

  def update
    set_vals = []
    values = self.attribute_values
    self.class.attributes.each do |attr|
      set_vals << "#{attr}=?"
    end
    set_vals = set_vals.join(", ")
    query =
      "UPDATE #{self.class.table_name}
       SET #{set_vals}
       WHERE id=?"

    DBConnection.execute(query, [*values, self.id])
    p "succesfully updated!"
  end

end
