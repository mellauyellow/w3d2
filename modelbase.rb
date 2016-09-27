class ModelBase
  # def self.find_by_id(id)
  #   target = QuestionDBConnection.instance.execute(<<-SQL, id)
  #     SELECT
  #       *
  #     FROM
  #       users
  #     WHERE
  #       id = ?
  #   SQL
  #   return nil unless target.length > 0
  #
  #   self.class.new(target.first)
  # end

  def initialize
  end
end
