require_relative 'questions_database'
require_relative 'question_follow'
require_relative 'question'
require_relative 'modelbase'


class User < ModelBase
  attr_accessor :fname, :lname

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)
  end

  def average_karma
    liked_questions = QuestionDBConnection.instance.execute(<<-SQL, @id)
      SELECT
        CAST(COUNT(question_likes.question_id) / COUNT(DISTINCT questions.id) AS FLOAT) AS average_karma
      FROM
        questions
      LEFT OUTER JOIN
        question_likes ON questions.id = question_likes.question_id
      WHERE
        questions.author = ?
      GROUP BY
        questions.author, question_likes.question_id
    SQL

    liked_questions.first.values.first
  end
end
