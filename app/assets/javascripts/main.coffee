$ =>
  col = new models.CoordinateCollection
  col.fetch error: (error) -> setTimeout col.fetch, 5000
  dashboard = new views.Dashboard collection: col