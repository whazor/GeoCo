div style: 'margin: 20px;', ->
  h1 'Coordinaten'
  table ->
    tr ->
      th 'Tijd'
      th 'Vossengroep'
      th 'Opgelost door'
      th 'Locatie'
    for hint in this.docs
      tr ->
        td -> hint.time.toLocaleTimeString().substring 0, 5
        td -> hint.fox_group
        td -> hint.solver.name
        td -> 
          a href: "http://maps.google.nl/maps?q=#{hint.location.longlat.x},+#{hint.location.longlat.y}", -> hint.location.raw
