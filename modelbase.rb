require 'byebug'

class ModelBase

  @@CLASS_TABLES = {
    'Question' => 'questions',
    'User' => 'users',
    'Reply' => 'replies',
    'QuestionFollow' => 'question_follows',
    'QuestionLike' => 'question_likes'
  }

  def self.all
    debugger
    table_name = @@CLASS_TABLES[self.to_s]
    data = QuestionDBConnection.instance.execute("SELECT * FROM #{table_name}")
    data.map { |datum| self.new(datum) }
  end

  def self.find_by_id(id)
    target = QuestionDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    return nil unless target.length > 0

    self.new(target.first)
  end

  def self.where(options)
    #need to change to include a query
    set_all = self.all
    answers = []
    set_all.each do |object|
      answers << object if options.keys.all? { |k| object[k] == options[k] } && !answers.include?(object)
    end

    answers
  end

  def initialize(options)
    options.each { |k, v| instance_variable_set("@#{k}", v) }
  end

  def save
    return update if @id

    instance_variables = self.instance_variables.map { |v| v.to_s }
    instance_variables.delete('@id')

    table_columns = instance_variables.map { |v| v.delete('@') }
    question_marks = Array.new(table_columns.length) { '?' }

    QuestionDBConnection.instance.execute(<<-SQL, '#{instance_variables.join(", ")}')
      INSERT INTO
        replies (#{table_columns.join(", ")})
      VALUES
        (#{question_marks.join(", ")})
      SQL
      @id = QuestionDBConnection.instance.last_insert_row_id
  end

  def update
    instance_variables = self.instance_variables.map { |v| v.to_s }
    instance_variables.delete('@id')

    table_columns = instance_variables.map do |v|
      v.delete('@')
      v += " = ?"
    end

    QuestionDBConnection.instance.execute(<<-SQL, '#{instance_variables.join(", ")}, @id')
      UPDATE
        #{@@CLASS_TABLES[self.to_s]}
      SET
        #{table_columns.join(", ")}
      WHERE
        id = ?
      SQL
  end
end
