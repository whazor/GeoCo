days = 'zo ma di wo do vr za'.split ' '
div "<b>Origineel</b> (#{@doc.location.sourceType}): #{@doc.get('location.raw')}"
div "<b>Geo</b>: #{@doc.location.longlat.x}, #{@doc.location.longlat.y}" unless @doc.location.sourceType is "longlat"
div "<b>Rijksdriehoek</b>: #{@doc.location.rdh.x} #{@doc.location.rdh.y}" unless @doc.location.sourceType is "rdh"
div "<b>Adres</b>: #{@doc.location.address}" unless @doc.location.sourceType is "address"
div "<b>Tijd</b>: #{days[@doc.time.getDay()]} #{@doc.time.toLocaleTimeString()}"
div "<b>Vossengroep</b>: #{@doc.fox_group}"
div "<b>Oplosser</b>: #{@doc.solver.name}"

a onclick: "if(!confirm('Weet je zeker dat je de hint wilt verwijderen?')) return false;", href: "/hint/#{@doc._id}/delete", -> "Verwijderen?"
