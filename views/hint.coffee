days = 'zo ma di wo do vr za'.split ' '
div "<b>Tijd</b>: #{days[@doc.time.getDay()]} #{@doc.time.toLocaleTimeString()}"
div "<b>Vossengroep</b>: #{@doc.fox_group}"
div "<b>Oplosser</b>: #{@doc.solver.name}"
