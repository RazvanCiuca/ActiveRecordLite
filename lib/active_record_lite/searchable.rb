require_relative './db_connection'

module Searchable
  def where(params)
    attrs = []
    vals = []
    params.each do |key, val|
      attrs << "#{key}=?"
      vals << val
    end

    query = "#{attrs.join(" AND ")}"
    if @query.nil?
      @query = query
      @vals = vals
    else
      @query = @query + " AND " + query
      @vals += vals
    end
    self
  end

  def force
    result = DBConnection.execute(<<-SQL,@vals)
    SELECT * FROM #{table_name}
    WHERE #{@query}
    SQL

    parse_all(result)
  end

end