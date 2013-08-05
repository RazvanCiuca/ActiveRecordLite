require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

class AssocParams
  attr_reader :foreign_key, :primary_key, :other_class, :other_table
  def other_class
    @other_class = @other_class_name.constantize
  end

  def other_table
    @other_table = other_class.table_name
  end
end

class BelongsToAssocParams < AssocParams
  def initialize(name, params)
    @other_class_name = params[:class_name] || name.to_s.camelize
    @primary_key = params[:primary_key] || :id
    @foreign_key = params[:foreign_key] || (name.to_s + "_id").to_sym
  end

  def type
  end
end

class HasManyAssocParams < AssocParams
  def initialize(name, params, self_class)
    @other_class_name = params[:class_name] || name.to_s.singularize.camelize
    @primary_key = params[:primary_key] || :id
    @foreign_key = params[:foreign_key] || name.to_s.underscore + "_id"
  end

  def type
  end
end

module Associatable
  def assoc_params
    @assoc_params = @assoc_params || {}
  end

  def belongs_to(name, params = {})
    aps = BelongsToAssocParams.new(name, params)
    assoc_params[name] = aps

    define_method(name.to_s) do
      query = "
        SELECT *
        FROM #{aps.other_table}
        WHERE #{aps.other_table}.id=#{self.send(aps.foreign_key)}"

      result = DBConnection.execute(query)
      aps.other_class.parse_all(result)
    end
  end

  def has_many(name, params = {})
    aps = HasManyAssocParams.new(name, params, self.class)

    define_method(name.to_s) do
      query = "
        SELECT #{aps.other_table}.*
        FROM #{aps.other_table} JOIN #{self.class.table_name}
        ON #{self.class.table_name}.id=#{aps.foreign_key.to_s}
        WHERE #{self.send(aps.primary_key)}=#{aps.foreign_key.to_s}"

      result = DBConnection.execute(query)
      aps.other_class.parse_all(result)
    end
  end

  def has_one_through(name, assoc1, assoc2)
    define_method(name.to_s) do
      through = self.class.assoc_params[assoc1]
      source = through.other_class.assoc_params[assoc2]

      query = "
        SELECT #{source.other_table}.*
        FROM #{source.other_table}
        JOIN #{through.other_table}
        ON #{source.other_table}.id=#{through.other_table}.#{source.foreign_key.to_s}
        JOIN #{self.class.table_name}
        ON #{self.class.table_name}.#{through.foreign_key}=#{through.other_table}.id
        WHERE #{self.send(through.primary_key)}=#{self.class.table_name}.#{through.primary_key.to_s}
      "

      result = DBConnection.execute(query)
      source.other_class.parse_all(result)
    end
  end
end




