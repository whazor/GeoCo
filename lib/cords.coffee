#
# Formules gemaakt door Ed Stevanhagen
# http://estevenh.home.xs4all.nl/1/frame/lndex.html
#

Math.roundfloat = (i, decimals) -> @round(i * @pow(10, decimals)) / @pow(10, decimals)

class Coordinate
  constructor: (@x, @y) -> @radius = 0
  cords: -> [@x, @y]

class Geographic extends Coordinate
  constructor: (@x, @y) ->
    @x = Math.roundfloat(@x, 7)
    @y = Math.roundfloat(@y, 7)
    @radius = 0

  to_triangular: ->
    f = @x; l = @y
    console.log [f,l]
    fmin = 6; fsec = 9.1
    lmin = 17;lsec = 34.305

    #if fmin != 0 or fsec != 0
    f = Math.floor(f) + fmin / 60 + fsec / 3600
    #if lmin != 0 or lsec != 0
    console.log l
    l = Math.floor(l) + lmin / 60 + lsec / 3600

    console.log l
    f = f - (-18.00 - 14.723 * (f - 52) - 1.029 * (l - 5)) / 100000;
    l = l - (+89.120 + 3.708 * (f - 52) - 17.176* (l - 5)) / 100000;

    x0 = 155000.00;y0 = 463000.00
    f0 = 52.15616056;l0 = 5.38763889

    c01=190066.98903; d10=309020.31810
    c11=-11830.85831; d02=  3638.36193
    c21=  -114.19754; d12=  -157.95222
    c03=   -32.38360; d20=    72.97141
    c31=    -2.34078; d30=    59.79734
    c13=    -0.60639; d22=    -6.43481
    c23=     0.15774; d04=     0.09351
    c41=    -0.04158; d32=    -0.07379
    c05=    -0.00661; d14=    -0.05419
    d40=    -0.03444

    df=(f - f0) * 0.36; dl=(l - l0) * 0.36

    dx =c01*dl + c11*df*dl + c21*Math.pow(df,2)*dl + c03*Math.pow(dl,3)
    dx+=c31*Math.pow(df,3)*dl + c13*df*Math.pow(dl,3) + c23*Math.pow(df,2)*Math.pow(dl,3)
    dx+=c41*Math.pow(df,4)*dl + c05*Math.pow(dl,5)
    x=x0 + dx
    x=Math.round(100*x)/100

    dy =d10*df + d20*Math.pow(df,2) + d02*Math.pow(dl,2) + d12*df*Math.pow(dl,2)
    dy+=d30*Math.pow(df,3) + d22*Math.pow(df,2)*Math.pow(dl,2) + d40*Math.pow(df,4)
    dy+=d04*Math.pow(dl,4) + d32*Math.pow(df,3)*Math.pow(dl,2) + d14*df*Math.pow(dl,4)
    y=y0 + dy
    y=Math.round(100*y)/100
    
    ding = (graden) ->
      g0  = graden
      gra = Math.floor(g0)
      g0  =(g0 - gra) * 60
      min = Math.floor(g0)
      sec =Math.round((g0 - min) * 60*1000)/1000
      if (sec==60)
        min=min+1; sec=0
      if (min==60)
        gra=gra+1; min=0
      g0

    t = new Triangular ding(x), ding(y)
    t.radius = @radius
    return t


class Triangular extends Coordinate
  constructor: (@x, @y) ->
    extend_number = (i) ->
      k = i.toString().length
      if k < 6 then i * Math.pow(10, (6 - k)) else i
    @x = extend_number(@x)
    @y = extend_number(@y)
    @radius = 0
  to_geographic: ->
    x0 = 155000.000;y0 = 463000.000
    f0 = 52.156160556;l0 =  5.387638889
    a01 =3236.0331637;b10 =5261.3028966
    a20 = -32.5915821;b11 = 105.9780241
    a02 = -0.2472814;b12 = 2.4576469
    a21 = -0.8501341;b30 = -0.8192156
    a03 = -0.0655238;b31 = -0.0560092
    a22 = -0.0171137;b13 = 0.0560089
    a40 = 0.0052771;b32 = -0.0025614
    a23 = -0.0003859;b14 = 0.0012770
    a41 = 0.0003314;b50 = 0.0002574
    a04 = 0.0000371;b33 = -0.0000973
    a42 = 0.0000143;b51 = 0.0000293
    a24 = -0.0000090;b15 = 0.0000291

    dx=(@x-x0)*Math.pow(10,-5); dy=(@y-y0)*Math.pow(10,-5)

    df = a01 * dy + a20 * Math.pow(dx,2) + a02 * Math.pow(dy,2) + a21 * Math.pow(dx,2) * dy + a03 * Math.pow(dy,3)
    df += a40 * Math.pow(dx,4) + a22 * Math.pow(dx,2) * Math.pow(dy,2) + a04 * Math.pow(dy,4) + a41 * Math.pow(dx,4) * dy
    df += a23 * Math.pow(dx,2) * Math.pow(dy,3) + a42 * Math.pow(dx,4) * Math.pow(dy,2) + a24 * Math.pow(dx,2) * Math.pow(dy,4)
    f = f0 + df/3600

    dl = b10 * dx + b11 * dx * dy + b30 * Math.pow(dx, 3) + b12 * dx * Math.pow(dy,2) + b31 * Math.pow(dx,3) * dy
    dl += b13 * dx * Math.pow(dy,3) + b50 * Math.pow(dx,5) + b32 * Math.pow(dx,3) * Math.pow(dy,2) + b14 * dx * Math.pow(dy,4)
    dl += b51 * Math.pow(dx,5) * dy + b33 * Math.pow(dx,3) * Math.pow(dy,3) + b15 * dx * Math.pow(dy,5)
    l = l0 + dl/3600

    # Convert 
    fWgs=f+(-96.862-11.714*(f-52)-0.125*(l-5))/100000
    lWgs=l+(-37.902+0.329*(f-52)-14.667*(l-5))/100000

    fWgs0 = fWgs
    fWgs1 = Math.floor(fWgs)
    fWgs0 = (fWgs0 - fWgs1) * 60
    fWgs2 = Math.floor(fWgs0)
    fWgs3 = Math.round((fWgs0 - fWgs2) * 60*1000)/1000
    if (fWgs3==60)
      fWgs2+=1
      fWgs3=0
    if (fWgs2==60)
      fWgs1+=1
      fWgs2=0

    lWgs0 = lWgs
    lWgs1 = Math.floor(lWgs)
    lWgs0 =(lWgs0 - lWgs1) * 60
    lWgs2 = Math.floor(lWgs0)
    lWgs3 =Math.round((lWgs0 - lWgs2) * 60*1000)/1000
    if (lWgs3==60)
      lWgs2+=1
      lWgs3=0
    if (lWgs2==60)
      lWgs1+=1
      lWgs2=0

    g = new Geographic fWgs, lWgs
    g.radius = @radius
    return g

t = new Triangular(21705, 45753)
console.log t
console.log t.to_geographic()
console.log t.to_geographic().to_triangular()

