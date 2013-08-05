require_relative './db_connection'

module Searchable
  def where(params)
    attrs = []
    vals = []
    params.each do |key, val|
      attrs << "#{key}=?"
      vals << val
    end

    query =
      "SELECT * FROM #{table_name}
       WHERE #{attrs.join(" AND ")}"

    result = DBConnection.execute(query, vals)
  end
end