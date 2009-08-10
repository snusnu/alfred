require 'utils'

class Post

  include DataMapper::Resource

  property :id,         Serial
  property :person_id,  Integer, :nullable => false
  property :body,       Text
  property :question,   Boolean, :nullable => false, :default => false
  property :created_at, DateTime

  belongs_to :person

  has n, :post_tags
  has n, :tags, :through => :post_tags

  is :self_referential, :through => 'QuestionAnswer',
    :parents  => :questions,
    :children => :answers

  def question?
    question
  end

  def answer?
    !questions.all.empty?
  end

  def has_answers?
    answers.all.size > 0
  end

  def tag_list
    tags.all.map { |t| t.name }.join(', ')
  end

  def tag_list=(list)
    Utils.tag_list(list).each do |tag|
      tags << Tag.first_or_create(:name => tag)
    end
  end

end
