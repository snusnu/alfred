class Metric

  include DataMapper::Resource
  include RailsMetrics::ORM::DataMapper

  property :id,         Serial

  property :name,       String,   :required => true
  property :duration,   Integer,  :required => true
  property :request_id, Integer
  property :parent_id,  Integer
  property :payload,    Object
  property :started_at, DateTime, :required => true
  property :created_at, DateTime

end
