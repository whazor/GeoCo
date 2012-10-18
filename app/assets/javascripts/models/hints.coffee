@models ||= {}

class Coordinate extends Backbone.Model

class @models.CoordinateCollection extends Backbone.Collection
    model: Coordinate
    url: '/coordinates'
