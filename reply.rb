require_relative 'question'
require_relative 'questions_database'
require_relative 'user'
require_relative 'modelbase'


class Reply < ModelBase
  attr_accessor :question_id, :parent_id, :user_id, :body

  def self.find_by_user_id(user_id)
    replies = QuestionDBConnection.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL
    return nil unless replies.length > 0

    replies.map { |reply| Reply.new(reply) }
  end

  def self.find_by_question_id(question_id)
    replies = QuestionDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL
    return nil unless replies.length > 0

    replies.map { |reply| Reply.new(reply) }
  end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @parent_id = options['parent_id']
    @user_id = options['user_id']
    @body = options['body']
  end

  def author
    User.find_by_id(user_id)
  end

  def question
    Question.find_by_id(@question_id)
  end

  def parent_reply
    @parent_id
  end

  def child_replies
    children = QuestionDBConnection.instance.execute(<<-SQL, @id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_id = ?
    SQL

    children.map { |child| Reply.new(child) }
  end
end
