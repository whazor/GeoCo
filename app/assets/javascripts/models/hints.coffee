@models ||= {}

class Coordinate extends Backbone.Model

class Hint extends Coordinate

class Hunt extends Coordinate

class HuntCollection extends Backbone.Collection
  model: Hunt
  url: '/coordinates'
class HintCollection extends Backbone.Collection
  model: Hint
  url: '/coordinates'
