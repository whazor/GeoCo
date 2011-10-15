days = 'zo ma di wo do vr za'.split ' '
div "<b>Ruw</b>: #{@doc.location.value.x} #{@doc.location.value.y}" if @doc.location.value.x
div "<b>Locatie</b>: #{@doc.longlat.x} #{@doc.longlat.y}"
div "<b>Tijd</b>: #{days[@doc.time.getDay()]} #{@doc.time.toLocaleTimeString()}"
div "<b>Vossengroep</b>: #{@doc.fox_group}"
div "<b>Oplosser</b>: #{@doc.solver.name}"

a onclick: "if(!confirm('Weet je zeker dat je de hint wilt verwijderen?')) return false;", href: "/hint/#{@doc._id}/delete", -> "Verwijderen?"
