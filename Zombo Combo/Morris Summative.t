%sounds on/off
%stages
%death animation
%Money/Buying
%objectives/levels/waves/
%level saving
%Use Time.Elapsed
%boost for every kill combo meter thing, combo activates, one shot kills for a time or unitl runs out press space to activate
%draw loading arcs around the player to indicate legitness
%ZOMBO COMBO!!!!!!!!
%Helped by the Wesley Said
% Waves
%adjust screens
%money

%------------------LevelandscoreVars-----------------
var znumber : int := 2
var kills : int := 0
var survtime : real := 0
var score : real := 0
var level : real

var wave : int := 1
var wavekills : int := 0
var wavetimer : int := 0
var wavechange : boolean := false
var dontrespawn : boolean := true
var zombieabsence : boolean := false
var zombieabsencetime : int := 0

var r : int := 0
var cash : int := 0
var cashtime : int := 0
type HighScore :
    record
	name : string
	score : int
    end record

var Hscore : array 1 .. 21 of HighScore
var placeholder : HighScore
var filenum, place : int := 0
var name : string := " "
var key : string (1)
var ANSint : array 0 .. 100 of int
var width : int := 0
var space : int := 0
var spacing : int := 0
var standfont : int := Font.New ("FangSong:14")
var standfont2 : int := Font.New ("FangSong:24")

var font : array 1 .. 10 of int %combo counter font
for i : 1 .. 10
    font (i) := Font.New ("serif:" + intstr (12 + i * 14))
end for
var curfont : int
var comboframe : int := 1
var fontcolour : int

var combo : int := 0
var combotimer : int := 0
var combofontchange : boolean := false
%------------------MechanicVars----------------------
%------------------Particles-------------------------
const MaxPart := 50
var cx, cy, phyp, pdifx, pdify : real
cx := 100
cy := 100
phyp := 0
var poriginx, poriginy, pendx, pendy : real
poriginx := 0
poriginy := 0
pendx := 1
pendy := 1
var Zpnum : int := 1
var Zhit : boolean := false
type Particle_Type :
    record
	x, y, vx, vy, difx, dify, hyp : real
    end record
var Particles : array 1 .. MaxPart of Particle_Type

type PiercePartCoords :
    record
	x, y : int
    end record

var PPierce : array 1 .. 20 of PiercePartCoords
var PierceNum : int := 0
%-----------Power-Ups-------------------------------
var reloadx, reloady : int := 0
var reloadpic : int := Pic.FileNew ("reload.bmp")
var reloadtimer : int := 0

var buygunmenu : boolean := false
var buypowermenu : boolean := false
%----------------------------------------------------
var x, y, button : int
var difx, dify, hyp, slope, inslope, b, inb, fx, fy, lx, ly, acux, acuy, acudifx, acudify, acuhyp : real
var zdifx, zdify, zhyp : real
var bulletpic : int := Pic.FileNew ("player1.bmp")
var zombiepic : int := Pic.FileNew ("zombie.bmp")
var background : int := Pic.FileNew ("background.jpg")
var titlepic : int := Pic.FileNew ("zombocombo.bmp")
var menupic : int := Pic.FileNew ("MainMenu.bmp")
var buygunpic : int := Pic.FileNew ("buy.bmp")
var buypowerpic : int := Pic.FileNew ("buy2.bmp")
var centered : boolean := true
var window : int := Window.Open ("graphics:1000;700")
var n, zh, ztime, ztime2 : int := 0
var bullet : % Player
    record
	x, y, vx, vy : real
	speed : real
	health : real
    end record

bullet.x := 500
bullet.y := 350
bullet.vx := 0
bullet.vy := 0
bullet.speed := 4
bullet.health := 100

acux := 0
acuy := 0

var backx, backy : int := 0  %universal x and y to make screen move
var unix, uniy : real := 0

type z : % zombies
    record
	x, y, vx, vy : real
	speed, slowspeed : real
	health : real
	angle, ztime, ztime2, picx, picy : int
	nangle : int
	sprite : int
	zslow : boolean
    end record


var zombie : array 1 .. 20 of z
var bulletsprite : int := Sprite.New (bulletpic) %player
var keys : array char of boolean

for i : 1 .. 20
    zombie (i).sprite := Sprite.New (zombiepic)
end for

View.Set ("offscreenonly")
setscreen ("nocursor")
%------------------Guns----------------------------------------
type guntype :
    record
	firerate, ammo, clip, clipsize : int
	pic : int
	acu, damage : real
	pierce, SingleShot, bought : boolean
    end record

var gun : array 1 .. 10 of guntype

for i : 1 .. 4
    gun (i).pic := Pic.FileNew ("gun" + intstr (i) + ".bmp")
end for

var gunmodel : int
var clicked : boolean := false
var switchtimer : real := 0
var shoottime, shootx, shooty : int := 0
var reloading : boolean := false
var dontshoot : boolean := false
%%%%%STATS%%%%%%%%%%%%
gun (1).firerate := 15 %pistol
gun (1).clipsize := 12
gun (1).acu := 0.1
gun (1).damage := 6
gun (1).pierce := false
gun (1).SingleShot := true

gun (2).firerate := 10 %MachineGun
gun (2).clipsize := 24
gun (2).acu := 0.15
gun (2).damage := 4
gun (2).pierce := false
gun (2).SingleShot := false

gun (3).firerate := 0 %Shotgun
gun (3).clipsize := 4
gun (3).acu := 0.5
gun (3).damage := 12
gun (3).pierce := false
gun (3).SingleShot := false

gun (4).firerate := 30 %Sniper
gun (4).clipsize := 5
gun (4).acu := 0.01
gun (4).damage := 12
gun (4).pierce := true
gun (4).SingleShot := true

%------------------Particles----------------------------------

procedure renewP (i : int, x, y : real)
    Particles (i).difx := x - cx + Rand.Int (-30, 30)
    Particles (i).dify := y - cy + Rand.Int (-30, 30)
    Particles (i).hyp := sqrt (Particles (i).difx ** 2 + Particles (i).dify ** 2)
    Particles (i).x := x
    Particles (i).y := y
    if not Particles (i).hyp = 0 then
	Particles (i).vx := Particles (i).difx / Particles (i).hyp * 10 %*round(2*(Rand.Int(0,1)-0.5)) %randmize the y position
	Particles (i).vy := Particles (i).dify / Particles (i).hyp * 10 %*round(2*(Rand.Int(0,1)-0.5)) %randmize the y position
    end if
end renewP

for i : 1 .. MaxPart % give particles their initial x,y value
    renewP (i, -100, -100)
    Particles (i).vx := 0
    Particles (i).vy := 0
end for

procedure Party
    phyp := sqrt ((poriginx - pendx) ** 2 + (poriginy - pendy) ** 2) %keeps particle dispersion uniform despite distance
    cx := poriginx + (poriginx - pendx) / phyp * 100
    cy := poriginy + (poriginy - pendy) / phyp * 100
    for i : 1 .. MaxPart
	Particles (i).x -= Particles (i).vx * Rand.Int (0, 5) %movement at different speeds
	Particles (i).y -= Particles (i).vy * Rand.Int (0, 5)
	Particles (i).vx := Particles (i).vx * 0.90 %slows down
	Particles (i).vy := Particles (i).vy * 0.90

	if abs (Particles (i).vx) < 1 or abs (Particles (i).vy) < 1 then
	    if Zhit = true then
		renewP (i, poriginx, poriginy)
	    end if
	else
	    Draw.ThickLine (round (Particles (i).x), round (Particles (i).y), round (Particles (i).x + Particles (i).difx * 0.1), round (Particles (i).y + Particles (i).dify * 0.1), 3, red)
	end if
    end for

    if cashtime > 0 then %draw money earned in kill
	cashtime -= 1
	Draw.Text (intstr (10 + combo * 10) + " $", round (Particles (1).x), round (Particles (1).y), standfont, 10)
    end if

end Party
%-------------------------------------------------------------
%Highscore Procedures----------------------------------------

procedure reset
    for i : 1 .. 20
	Hscore (i).name := chr (i + 96) + "lob"
	Hscore (i).score := 1000 - i * 25
    end for
    open : filenum, "scores", write
    for i : 1 .. 20
	write : filenum, Hscore (i)
    end for
    close : filenum
end reset

procedure replace
    if key = "0" then
	for i : 1 .. 10
	    Hscore (9 + i).name := Hscore (10 + i).name
	    Hscore (9 + i).score := Hscore (10 + i).score
	end for
    else
	for i : 1 .. 20 - strint (key)
	    Hscore (strint (key) - 1 + i).name := Hscore (strint (key) + i).name
	    Hscore (strint (key) - 1 + i).score := Hscore (strint (key) + i).score
	end for
    end if
    open : filenum, "scores", write
    for i : 1 .. 20
	write : filenum, Hscore (i)
    end for
    close : filenum
end replace

procedure HS
    Input.Flush
    open : filenum, "scores", read
    for i : 1 .. 20
	read : filenum, Hscore (i)
    end for
    close : filenum

    Hscore (21).score := round (score)

    if Hscore (21).score > Hscore (10).score then
	Pic.Draw (background, -40, 0, picCopy)     %background
	Font.Draw ("Good job, enter your name below", 200, 360, Font.New ("serif:18"), white)
	for i : 1 .. 35
	    drawfillbox (0, 395, 700, 425, red)
	    drawfillbox (0, 295, i * 20, 320, white)
	    Font.Draw ("HIGHSCORE ! ! !", i * 10 - 100, 400, Font.New ("serif:24"), white)
	    View.Update
	    delay (15)
	end for

	drawline (150, 317, 165, 307, black)     %Draw little triangle
	drawline (150, 317, 150, 297, black)
	drawline (165, 307, 150, 297, black)
	drawfill (160, 307, black, black)
	View.Update
	space := 0
	name := " "
	loop     %gets username
	    var key : string (1)
	    Input.Flush
	    getch (key)

	    if ord (key) = 8 and space > 0 then

		drawfillbox (250 + spacing - 1, 295, 250 + spacing + Font.Width (chr (ANSint (space)), standfont) + 1, 320, white)
		spacing -= Font.Width (chr (ANSint (space)), standfont)
		space -= 1
	    elsif not ord (key) = 8 and space < 18 then
		space += 1
		spacing += width
		ANSint (space) := ord (key)
		Draw.Text (key, 250 + (spacing), 300, standfont, black)
		width := Font.Width (key, standfont)
	    end if
	    View.Update
	    exit when ord (key) = 10
	end loop

	for i : 1 .. space
	    name := name + chr (ANSint (i))
	end for
	Hscore (21).name := name
    end if

    for j : 1 .. 20
	for i : 1 .. 20
	    if Hscore (i).score < Hscore (i + 1).score then
		placeholder := Hscore (i)
		Hscore (i) := Hscore (i + 1)
		Hscore (i + 1) := placeholder
	    end if
	end for
    end for
    Pic.Draw (background, -40, 0, picCopy)     %background

    for i : 1 .. 10     %drawing highscores
	drawfillbox (0, 395, 700, 425, red)
	Font.Draw ("HIGHSCORES", i * 35 - 100, 400, Font.New ("serif:24"), white)
	Font.Draw (intstr (i) + ".", 160, 380 - (i * 25), Font.New ("serif:18"), white)
	Font.Draw (Hscore (i).name, 200, 380 - (i * 25), Font.New ("serif:18"), white)
	Font.Draw (intstr (Hscore (i).score), 450, 380 - (i * 25), Font.New ("serif:18"), white)
	View.Update
	delay (50)
    end for

    open : filenum, "scores", write
    for i : 1 .. 20
	write : filenum, Hscore (i)
    end for
    close : filenum

    Font.Draw ("Press any key to play again", 250, 80, Font.New ("serif:12"), white)

    getch (key)
    mousewhere (x, y, button)
    if key = "`" and button = 1 then
	reset
    elsif ord (key) > 47 and ord (key) < 58 and button = 1 then
	replace
    end if
end HS
%------------------------------------------------------------

process gunshot
    Music.PlayFile ("gunshot2.wav")
end gunshot

%spritepointing-----------------------------------------



var robullet : array 1 .. 5 of array 0 .. 180 of int   %player sprite pointing

robullet (1) (0) := Pic.FileNew ("player1.bmp")
robullet (2) (0) := Pic.FileNew ("player2.bmp")
robullet (3) (0) := Pic.FileNew ("player3.bmp")
robullet (4) (0) := Pic.FileNew ("player4.bmp")
robullet (5) (0) := Pic.FileNew ("player5.bmp")


for i : 1 .. 4
    for angle : 1 .. 180
	robullet (i) (angle) := Pic.Rotate (robullet (i) (0), 2 * angle, 30, 30)
    end for
end for

var angle : int := 0
%-------------------------------------------------------
var rozombie : array 0 .. 180 of int     %zombie sprite pointing

rozombie (0) := Pic.FileNew ("zombie.bmp")

for zangle : 1 .. 180
    rozombie (zangle) := Pic.Rotate (rozombie (0), 2 * zangle, 40, 40)

end for

var zangle : int := 0

%-------------------------------------------------------
procedure Bullet
    %spritepointing-----------------------------------------
    if x = bullet.x then
	angle := 0
    elsif x < bullet.x then
	angle := round ((arctand ((bullet.y - y) / (bullet.x - x)) + 90) / 2)
    else
	angle := round ((arctand ((bullet.y - y) / (bullet.x - x)) + 270) / 2)
    end if
    Sprite.ChangePic (bulletsprite, robullet (gunmodel) (angle))
    %-------------------------------------------------------
    %spritemoving-----------------------------------------
    Input.KeyDown (keys)
    if keys ('w') and backy > -1660 then
	if keys ('a') or keys ('d') then
	    uniy := -2.122 - (combo * 0.25)
	else
	    uniy := -3 - (combo * 0.25)
	end if
    end if
    if keys ('s') and backy < -320 then
	if keys ('a') or keys ('d') then
	    uniy := 2.122 + (combo * 0.25)
	else
	    uniy := 3 + (combo * 0.25)
	end if
    end if
    if keys ('a') and backx < -450 then
	if keys ('w') or keys ('s') then
	    unix := 2.122 + (combo * 0.25)
	else
	    unix := 3 + (combo * 0.25)
	end if
    end if
    if keys ('d') and backx > -3160 then
	if keys ('w') or keys ('s') then
	    unix := -2.122 - (combo * 0.25)
	else
	    unix := -3 - (combo * 0.25)
	end if
    end if
    %-------------------------------------------------------

    Sprite.SetPosition (bulletsprite, 500, 350, centered)
end Bullet
%-------------------------------------------------------

procedure Zombie
    for i : 1 .. znumber

	if zombie (i).health < 0 then


	    if Rand.Int (1, 2 + znumber div 5) = 1 and reloadtimer = 0 then % reload pickup
		reloadx := round (zombie (i).x)
		reloady := round (zombie (i).y)
		reloadtimer := 500
	    end if

	    combo += 1

	    kills += 1

	    cash += 10 + (10 * combo)
	    cashtime := 50

	    zombie (i).health := 10

	    if kills + znumber - 2 > wavekills then

		%if end of wave zombies spawn far away
		zombie (i).x := Rand.Int (-1000000, maxx + 1000000)
		zombie (i).y := Rand.Int (0, 1) * (maxy + 1000000) - 1000000


	    else

		if Rand.Int (0, 2) > 1 then %respawn
		    zombie (i).x := Rand.Int (-100, maxx + 200)
		    zombie (i).y := Rand.Int (0, 1) * (maxy + 200) - 100
		else
		    zombie (i).x := Rand.Int (0, 1) * (maxx + 200) - 100
		    zombie (i).y := Rand.Int (-100, maxy + 200)
		end if

	    end if



	else           %if not zombie (i).ztime > 0 then
	    if bullet.x = zombie (i).x then
		zombie (i).angle := 0
	    elsif bullet.x < zombie (i).x then
		zombie (i).angle := round ((arctand ((zombie (i).y - bullet.y) / (zombie (i).x - bullet.x)) + 90) / 2)
	    else
		zombie (i).angle := round ((arctand ((zombie (i).y - bullet.y) / (zombie (i).x - bullet.x)) + 270) / 2)
	    end if
	    if not zombie (i).nangle = zombie (i).angle then
		if abs (zombie (i).nangle - zombie (i).angle) > 90 and abs (zombie (i).nangle - zombie (i).angle) < 180 then
		    zombie (i).nangle += round ((zombie (i).nangle - zombie (i).angle) / abs (zombie (i).nangle - zombie (i).angle))
		    if zombie (i).nangle < 0 then
			zombie (i).nangle := 179
		    end if
		    if zombie (i).nangle > 180 then
			zombie (i).nangle := 1
		    end if
		else
		    zombie (i).nangle -= round ((zombie (i).nangle - zombie (i).angle) / abs (zombie (i).nangle - zombie (i).angle))
		    if zombie (i).nangle > 180 then
			zombie (i).nangle := 1
		    end if
		    if zombie (i).nangle < 0 then
			zombie (i).nangle := 179
		    end if
		end if
	    end if
	    Sprite.ChangePic (zombie (i).sprite, rozombie (zombie (i).nangle))

	    for j : 1 .. znumber     %prevents grouping
		if (zombie (i).x - zombie (j).x) ** 2 + (zombie (i).x - zombie (j).x) ** 2 < 1000 and (i) < (j) then
		    zombie (i).zslow := true
		else
		    zombie (i).zslow := false
		end if
	    end for



	    if zombie (i).zslow = true then
		zombie (i).ztime := 0
		zombie (i).slowspeed := Rand.Int (-3, 3)
	    end if

	    if zombie (i).ztime < 20 then
		zombie (i).ztime += 1
	    end if

	    zdifx := bullet.x - zombie (i).x     %vector stuff
	    zdify := bullet.y - zombie (i).y
	    zhyp := sqrt (zdifx ** 2 + zdify ** 2)
	    if abs (zombie (i).nangle - zombie (i).angle) > 90 then
		if abs (abs (zombie (i).nangle - zombie (i).angle) - 180) < 5 then
		    zombie (i).vx := zdifx / zhyp * zombie (i).speed
		    zombie (i).vy := zdify / zhyp * zombie (i).speed
		else
		    zombie (i).vx := zdifx / zhyp * (0.1 * zombie (i).speed)
		    zombie (i).vy := zdify / zhyp * (0.1 * zombie (i).speed)
		end if
	    else
		if abs (zombie (i).nangle - zombie (i).angle) < 5 then
		    zombie (i).vx := zdifx / zhyp * zombie (i).speed
		    zombie (i).vy := zdify / zhyp * zombie (i).speed
		else
		    zombie (i).vx := zdifx / zhyp * (0.1 * zombie (i).speed)
		    zombie (i).vy := zdify / zhyp * (0.1 * zombie (i).speed)
		end if
	    end if
	    if not zombie (i).ztime < 20 then
		zombie (i).x += zombie (i).vx * zombie (i).slowspeed * 0.4
		zombie (i).y += zombie (i).vy * zombie (i).slowspeed * 0.4 * -1
	    end if
	    zombie (i).x += zombie (i).vx + unix
	    zombie (i).y += zombie (i).vy + uniy

	    Sprite.SetPosition (zombie (i).sprite, round (zombie (i).x), round (zombie (i).y), centered)
	end if
    end for
end Zombie

procedure Reload
    if gun (gunmodel).ammo > gun (gunmodel).clipsize then
	gun (gunmodel).ammo -= gun (gunmodel).clipsize - gun (gunmodel).clip
	gun (gunmodel).clip := gun (gunmodel).clipsize
    else
	gun (gunmodel).clip := gun (gunmodel).ammo
	gun (gunmodel).ammo := 0
    end if
end Reload

function Contact (x, y, x1, y1, x2, y2 : int) : boolean
    result (x > x1) and (x < x2) and (y > y1) and (y < y2)
end Contact

procedure DrawShoot (x, y : int)
    Draw.ThickLine (round (bullet.x), round (bullet.y), x, y, 3, 30) %drawsbulletstreak
    Draw.Line (round (bullet.x), round (bullet.y), x, y, white) %only happens if none are hit instead of some arnt hit
end DrawShoot

procedure ZombieHit     %check if bullet hits zombie and shooting animation
    acux := x + Rand.Int (-10, 10) * hyp * gun (gunmodel).acu / 10
    acuy := y + Rand.Int (-10, 10) * hyp * gun (gunmodel).acu / 10
    difx := acux - bullet.x          %Inacuracy
    dify := acuy - bullet.y          %Inacuracy
    hyp := sqrt (difx ** 2 + dify ** 2)
    if round (bullet.x + difx / hyp * 3000) - round (bullet.x) = 0 then
	slope := (round (bullet.y + dify / hyp * 3000) - round (bullet.y)) / (round (bullet.x + difx / hyp * 3000) - round (bullet.x) + 0.01)
    else
	slope := (round (bullet.y + dify / hyp * 3000) - round (bullet.y)) / (round (bullet.x + difx / hyp * 3000) - round (bullet.x))
    end if
    if slope = 0 then
	inslope := 1 / (slope + 0.01) * -1
    else
	inslope := 1 / slope * -1
    end if
    b := round (bullet.y) - slope * round (bullet.x)
    gun (gunmodel).clip -= 1
    lx := 5000
    ly := 5000
    for i : 1 .. znumber
	inb := round (zombie (i).y) - inslope * round (zombie (i).x)
	fx := (inb - b) / (slope - inslope)
	fy := slope * fx + b
	if not zombie (i).x - fx = 0 and not zombie (i).y - fy = 0 and not fx - bullet.x = 0 and not hyp = 0 then
	    if sqrt ((zombie (i).x - fx) ** 2 + (zombie (i).y - fy) ** 2) < 25 and ((bullet.x + difx / hyp * 3000) - bullet.x) / (fx - bullet.x) > 0 then %bullet hits
		Zpnum := i

		if gun (gunmodel).pierce = true then
		    PierceNum += 1
		    zombie (i).health -= gun (gunmodel).damage
		    %-----combocounter-------

		    combotimer := 100
		    combofontchange := true
		    fontcolour := 10
		    %-------------
		    PPierce (PierceNum).x := round (zombie (i).x)
		    PPierce (PierceNum).y := round (zombie (i).y)
		    if not zombie (i).y - bullet.y = 0 then
			zombie (i).x -= zombie (i).vx * 10 %knockback
			zombie (i).y -= zombie (i).vy * 10
		    end if
		end if
		if ((bullet.x - fx) ** 2 + (bullet.y - fy) ** 2) < ((bullet.x - lx) ** 2 + (bullet.y - ly) ** 2) then
		    lx := fx
		    ly := fy
		    zh := i
		end if
	    end if
	end if
    end for
    if lx < 5000 and ly < 5000 and gun (gunmodel).pierce = false then %if bullet hits
	%-----combocounter-------

	combotimer := 100
	combofontchange := true
	fontcolour := 10
	%-------------
	shootx := round (lx)
	shooty := round (ly)
	Zhit := true
	zombie (zh).health -= gun (gunmodel).damage                    %should only apply the closest
	poriginx := zombie (zh).x
	poriginy := zombie (zh).y
	pendx := bullet.x
	pendy := bullet.y
	if not zombie (zh).y - bullet.y = 0 then
	    zombie (zh).x -= zombie (zh).vx * 10     %knockback
	    zombie (zh).y -= zombie (zh).vy * 10
	end if
    else %if bullet misses or pierces
	shootx := round (bullet.x + difx / hyp * 2000)
	shooty := round (bullet.y + dify / hyp * 2000)
    end if

end ZombieHit

procedure BulletHit     %check if player takes damage by being near zombie
    if bullet.health < 100 then
	bullet.health += 0.1
    end if
    for i : 1 .. znumber
	if (bullet.x - zombie (i).x) ** 2 + (bullet.y - zombie (i).y) ** 2 < 600 then
	    bullet.health -= 2
	    Zhit := true
	    poriginx := bullet.x
	    poriginy := bullet.y
	    pendx := zombie (i).x
	    pendy := zombie (i).y
	end if
    end for
    drawfillbox (98, 673, 202, 687, 30)
    if bullet.health > 0 then
	drawfillbox (100, 675, 100 + round (bullet.health), 685, green)
    end if
    Draw.Text ("HEALTH", 30, 675, standfont, 30)
end BulletHit

procedure GunMenu
    if Contact (round (bullet.x), round (bullet.y), 2526 + backx, 1326 + backy, 2638 + backx, 1415 + backy) = true then %gun buying
	Draw.Text ("Press E to buy Guns and Ammo ", 390, 400, standfont, white)

	if switchtimer <= 0 and keys ('e') then
	    if buygunmenu = false then
		buygunmenu := true
	    elsif buygunmenu = true then
		buygunmenu := false
	    end if
	    switchtimer := 10
	end if

	if buygunmenu = true then
	    dontshoot := true
	    drawfillbox (200, 100, 800, 300, grey)
	    for i : 1 .. 4
		drawfillbox (110 + i * 135, 250, 220 + i * 135, 290, 22)
		drawfillbox (110 + i * 135, 150, 220 + i * 135, 190, 22)
		drawfillbox (110 + i * 135, 200, 220 + i * 135, 240, 22)
		Draw.Text ("BUY GUN", 115 + i * 135, 210, standfont, white)

		if gun (i).bought = true then
		    drawfillbox (110 + i * 135, 250, 220 + i * 135, 290, black)
		    drawfillbox (110 + i * 135, 200, 220 + i * 135, 240, black)
		    Draw.Text ("BUY AMMO", 115 + i * 135, 160, standfont, white)
		    Draw.Text (intstr (gun (i).ammo) + " bullets", 110 + i * 135, 135, standfont, white)
		end if

		Pic.Draw (gun (i).pic, 110 + i * 135, 250, picMerge)
	    end for
	    %-----------------draw-gun-buying---------------------------------------------------------------

	    if Contact (x, y, 380, 200, 490, 240) = true and gun (2).bought = false then %machine
		drawfillbox (380, 200, 490, 240, 24)
		Draw.Text ("COST: 1000$", 380, 210, standfont, white)
		if button = 1 and cash > 1000 and switchtimer <= 0 then
		    gun (2).bought := true
		    cash -= 1000
		end if
	    end if


	    if Contact (x, y, 515, 200, 625, 240) = true and gun (3).bought = false then %shot
		drawfillbox (515, 200, 625, 240, 24)
		Draw.Text ("COST: 500$", 515, 210, standfont, white)
		if button = 1 and cash > 500 and switchtimer <= 0then
		    gun (3).bought := true
		    cash -= 500
		end if
	    end if


	    if Contact (x, y, 650, 200, 760, 240) = true and gun (4).bought = false then %sniper
		drawfillbox (650, 200, 760, 240, 24)
		Draw.Text ("COST: 900$", 650, 210, standfont, white)
		if button = 1 and cash > 900 and switchtimer <= 0 then
		    gun (4).bought := true
		    cash -= 900
		end if
	    end if
	    %--------------draw-ammo-buying-------------------------------------------------------------------------------------
	    if Contact (x, y, 245, 150, 355, 190) = true and gun (1).bought = true and gun (1).ammo < gun (1).clipsize * 10 then %pistol
		drawfillbox (245, 150, 355, 190, 24)
		Draw.Text ("COST: 100$", 245, 160, standfont, white)
		if button = 1 and cash > 100 and switchtimer <= 0 then
		    gun (1).ammo += gun (1).clipsize
		    cash -= 100
		end if
	    end if


	    if Contact (x, y, 380, 150, 490, 190) = true and gun (2).bought = true and gun (2).ammo < gun (2).clipsize * 10 then %machine
		drawfillbox (380, 150, 490, 190, 24)
		Draw.Text ("COST: 300$", 380, 160, standfont, white)
		if button = 1 and cash > 300 and switchtimer <= 0 then
		    gun (2).ammo += gun (2).clipsize
		    cash -= 300
		end if
	    end if


	    if Contact (x, y, 515, 150, 625, 190) = true and gun (3).bought = true and gun (3).ammo < gun (3).clipsize * 30 then %shot
		drawfillbox (515, 150, 625, 190, 24)
		Draw.Text ("COST: 10$", 515, 160, standfont, white)
		if button = 1 and cash > 10 and switchtimer <= 0 then
		    gun (3).ammo += gun (3).clipsize
		    cash -= 10
		end if
	    end if


	    if Contact (x, y, 650, 150, 760, 190) = true and gun (4).bought = true and gun (4).ammo < gun (4).clipsize * 10 then %sniper
		drawfillbox (650, 150, 760, 190, 24)
		Draw.Text ("COST: 200$", 650, 160, standfont, white)
		if button = 1 and cash > 200 and switchtimer <= 0 then
		    gun (4).ammo += gun (4).clipsize
		    cash -= 200
		end if
		
	    if button = 1 then 
	    switchtimer := 10
	    end if
	    
	    end if
	    %--------------------------------------------------------------------------------
	end if
    else
	buygunmenu := false
    end if
end GunMenu


procedure TitlePage
    Pic.Draw (titlepic, 0, 0, picCopy)     %background
    Font.Draw ("! WARNING: EXTREME GRAPHIC VIOLENCE ! ", 300, 670, Font.New ("serif:14"), brightred)
    Font.Draw ("BELL HIGH SCHOOL                                                            COMPSCI PROJECT 2015                                                       KENTA MORRIS", 150, 20,
	Font.New ("serif:10"), brightred)
    Font.Draw ("(Press any key to start)", 420, 150, Font.New ("serif:14"), white)


    zombie (1).sprite := Sprite.New (zombiepic)
    Sprite.SetHeight (bulletsprite, 1)
    Sprite.Show (bulletsprite)
    Sprite.SetHeight (zombie (1).sprite, 0)
    Sprite.Show (zombie (1).sprite)
    Sprite.SetPosition (bulletsprite, 2000, 280, centered)
    Sprite.SetPosition (zombie (1).sprite, 2000, 180, centered)


    View.Update
    getch (key)
end TitlePage

procedure MainMenu
    loop
	mousewhere (x, y, button)
	Pic.Draw (menupic, 0, 0, picCopy) %background
	drawfillbox (0, 540, 500, 600, red) %Menu
	Draw.Text ("Main Menu", 100, 560, Font.New ("FangSong:26"), white)

	if Contact (x, y, 0, 460, 350, 500) = true then
	    drawfillbox (100, 460, 350, 500, red) %Countinue
	    Draw.Text ("COUNTINUE", 170, 470, standfont, white)
	    exit when button = 1
	else
	    drawfillbox (0, 460, 250, 500, red)
	    Draw.Text ("COUNTINUE", 70, 470, standfont, white)
	end if

	if Contact (x, y, 0, 380, 350, 420) = true then
	    drawfillbox (100, 380, 350, 420, red) %NewGame
	    Draw.Text ("NEW GAME", 170, 390, standfont, white)
	else
	    drawfillbox (0, 380, 250, 420, red)
	    Draw.Text ("NEW GAME", 70, 390, standfont, white)
	end if

	if Contact (x, y, 0, 300, 350, 340) = true then
	    drawfillbox (100, 300, 350, 340, red) %Tutorial
	    Draw.Text ("TUTORIAL", 170, 310, standfont, white)
	else
	    drawfillbox (0, 300, 250, 340, red)
	    Draw.Text ("TUTORIAL", 70, 310, standfont, white)
	end if

	if Contact (x, y, 0, 220, 350, 260) = true then
	    drawfillbox (100, 220, 350, 260, red) %Highscore
	    Draw.Text ("HIGHSCORE", 170, 230, standfont, white)
	else
	    drawfillbox (0, 220, 250, 260, red)
	    Draw.Text ("HIGHSCORE", 70, 230, standfont, white)
	end if

	if Contact (x, y, 0, 140, 350, 180) = true then
	    drawfillbox (100, 140, 350, 180, red) %Options
	    Draw.Text ("OPTIONS", 170, 150, standfont, white)
	else
	    drawfillbox (0, 140, 250, 180, red)
	    Draw.Text ("OPTIONS", 70, 150, standfont, white)
	end if

	if Contact (x, y, 0, 60, 350, 100) = true then
	    drawfillbox (100, 60, 350, 100, red) %Credits
	    Draw.Text ("CREDITS", 170, 70, standfont, white)
	else
	    drawfillbox (0, 60, 250, 100, red)
	    Draw.Text ("CREDITS", 70, 70, standfont, white)
	end if


	View.Update
    end loop
end MainMenu
%----------------------------------------------------------------------------

TitlePage

loop     %loop lets you restart
    gunmodel := 1

    for i : 1 .. 4
	gun (i).clip := gun (i).clipsize
	gun (i).ammo := 0
	gun (i).bought := false
    end for

    gun (1).bought := true
    gun (1).ammo := 120

    bullet.health := 100
    score := 0
    znumber := 4
    survtime := 0

    wave := 1
    wavekills := 8

    kills := 0
    bullet.x := 500
    bullet.y := 350
    backx := -1800
    backy := -1000
    for i : 1 .. 20
	zombie (i).x := 0
	zombie (i).y := 0
	zombie (i).picx := 0
	zombie (i).picy := 0
	zombie (i).vx := 0
	zombie (i).vy := 0
	zombie (i).speed := (3 + ((1.5 * i) / 20))
	zombie (i).slowspeed := 0
	zombie (i).health := 10
	zombie (i).angle := 0
	zombie (i).nangle := 0
	zombie (i).ztime := 0
	zombie (i).ztime2 := -50
	zombie (i).zslow := false
    end for

    MainMenu

    Sprite.SetHeight (bulletsprite, 1)
    Sprite.Show (bulletsprite)

    for i : 1 .. 20
	Sprite.SetHeight (zombie (i).sprite, 0)
	Sprite.Show (zombie (i).sprite)
    end for

    for i : 1 .. 20
	if Rand.Int (0, 2) > 1 then
	    zombie (i).x := Rand.Int (-100, maxx + 200)
	    zombie (i).y := Rand.Int (0, 1) * (maxy + 200) - 100
	else
	    zombie (i).x := Rand.Int (0, 1) * (maxx + 200) - 100
	    zombie (i).y := Rand.Int (-100, maxy + 200)
	end if
	Sprite.SetPosition (zombie (i).sprite, round (zombie (i).x), round (zombie (i).y), centered)
    end for
    %-------------------------------------------------------



    loop     %loop that contain main game

	mousewhere (x, y, button)

	unix := 0
	uniy := 0

	if n > 0 then
	    n -= 1
	end if
	survtime += 0.015
	score := survtime + (kills * 50)

	Bullet
	Zombie

	backx += round (unix)
	backy += round (uniy)

	Pic.Draw (background, backx, backy, picCopy)   %background

	BulletHit
	difx := x - bullet.x % + Rand.Int(-30,30)          %Inacuracy
	dify := y - bullet.y % + Rand.Int(-30,30)           %Inacuracy
	hyp := sqrt (difx ** 2 + dify ** 2)

	if button = 1 and n = 0 and gun (gunmodel).clip > 0 and dontshoot = false then     %shooting
	    if gun (gunmodel).SingleShot = false or clicked = false then
		ZombieHit
		n := gun (gunmodel).firerate
		%  fork gunshot
		if gun (gunmodel).SingleShot = true then
		    clicked := true
		end if
		shoottime := 3
	    end if
	elsif gun (gunmodel).SingleShot = true and n = 0 then
	    clicked := false
	end if

	if reloadtimer > 0 then % reload pickups
	    reloadx += round (unix)
	    reloady += round (uniy)
	    reloadtimer -= 1
	    if Contact (500, 350, reloadx - 10, reloady - 40, reloadx + 40, reloady) = true then %Insta Reload
		reloadtimer := 0
		Reload
		n := 0
	    end if
	    Pic.Draw (reloadpic, reloadx - 20, reloady - 50, picMerge)
	end if

	%-----------Wave leveling system-------------------------------------------------------------------------------
	if kills = wavekills then
	    wavechange := true
	    wavetimer := 1000
	end if

	if wavetimer > 0 then
	    wavetimer -= 1
	    if wavetimer < 999 then
		zombieabsencetime := 0
		zombieabsence := false
		drawfillbox (0, 500, (1000 - wavetimer) * 10, 530, red)
		if wavetimer < 900 then
		    Draw.Text ("NEXT WAVE IN " + intstr (wavetimer div 20), 420, 504, standfont, white)
		end if
	    end if
	end if

	if wavetimer = 0 and wavechange = true then
	    wave += 1
	    wavekills += 5 + wave * 4

	    if znumber < 20 then
		znumber += 1
	    end if

	    for i : 1 .. znumber
		zombie (i).speed := (3 + ((1.5 * i) / 20)) + 0.05 * wave %increasing number and speed per wave
	    end for
	    wavechange := false
	end if


	if wavekills - kills < wave - 2 and zombieabsence = false then
	    zombieabsencetime := 400
	    zombieabsence := true
	end if

	if zombieabsencetime > 0 then
	    zombieabsencetime -= 1
	elsif zombieabsence = true then
	    zombieabsence := false
	    kills += 1
	    wavechange := true
	    wavetimer := 1000
	end if


	if wavetimer = 1 then
	    for i : 1 .. znumber
		if Rand.Int (0, 2) > 1 then %respawn zombies at begining of next wave
		    zombie (i).x := Rand.Int (-100, maxx + 200)
		    zombie (i).y := Rand.Int (0, 1) * (maxy + 200) - 100
		else
		    zombie (i).x := Rand.Int (0, 1) * (maxx + 200) - 100
		    zombie (i).y := Rand.Int (-100, maxy + 200)
		end if
	    end for
	end if

	%-------------------combo-counter--------------------------------------------
	if combotimer > 0 and combo > 0 then
	    combotimer -= 1
	    drawarc (900, 580, 35, 35, round (90 + combotimer * 3.6), 90, fontcolour)
	    drawarc (900, 580, 36, 36, round (90 + combotimer * 3.6), 90, fontcolour)
	    drawarc (900, 580, 37, 37, round (90 + combotimer * 3.6), 90, fontcolour)
	    drawarc (900, 580, 38, 38, round (90 + combotimer * 3.6), 90, fontcolour)

	    Draw.Text ("X " + intstr (combo + 1), 900, 675, standfont, 10)

	    if combotimer < 25 then
		comboframe := 3
		fontcolour := 12
	    end if
	else
	    combo := 0
	    fontcolour := 10
	end if

	if combofontchange = true and comboframe < 5 and combo > 0 then
	    comboframe += 1
	else
	    combofontchange := false
	    comboframe := 1
	end if

	curfont := font (comboframe)
	Draw.Text (intstr (combo), 900 - 6 * comboframe - Font.Width (intstr (combo), curfont) div 2, 580 - 6 * comboframe, curfont, fontcolour)
	%-------------------------------------------------------------------------------

	if shoottime > 0 then     % draws the bullet streak for 3 runs
	    shoottime -= 1
	    DrawShoot (shootx, shooty)
	end if

	if keys ('r') and n = 0 or gun (gunmodel).clip = 0 and reloading = false then
	    reloading := true
	    if not gun (gunmodel).ammo + gun (gunmodel).clip = 0 then
		n := 105     %reload delay
	    end if
	end if

	if reloading = true and n = 0 then
	    Reload
	    reloading := false
	end if

	if keys ('q') and switchtimer <= 0 then
	    if reloading = true then    % reload cancel
		n := 0
		reloading := false
	    end if
	    if gunmodel < 4 then

		gunmodel += 1
	    else
		gunmodel := 1
	    end if

	    if gun (gunmodel).bought = false then %keeps cycling until a bought gun is found
		if gunmodel < 4 then

		    gunmodel += 1
		else
		    gunmodel := 1
		end if
	    end if

	    switchtimer := 10
	end if
	switchtimer -= 1

	if PierceNum > 1 then
	    poriginx := PPierce (PierceNum).x
	    poriginy := PPierce (PierceNum).y
	    pendx := bullet.x
	    pendy := bullet.y
	    PierceNum -= 1
	    Zhit := true
	end if

	Party     %draw particles
	Zhit := false
	exit when bullet.health < 1

	Draw.Text ("SCORE: " + intstr (round (score)), 350, 675, standfont, 30)
	Draw.Text ("WAVE: " + intstr (wave), 820, 50, standfont2, 30)
	Draw.Text ("KILLS: " + intstr (kills), 600, 675, standfont, 30)
	Draw.Text ("CASH: ", 760, 675, standfont, 30)
	Draw.Text ("COMBO: ", 760, 580, standfont, 30)
	if cashtime > 0 then
	    Draw.Text (intstr (cash) + " $", 820, 675, standfont, 10)
	else
	    Draw.Text (intstr (cash) + " $", 820, 675, standfont, 30)
	end if


	if n > 0 and gun (gunmodel).clip = gun (gunmodel).clipsize or n > gun (gunmodel).firerate then     %Draw cross hair
	    Draw.Arc (x, y, 23, 23, 90, round (90 + ((n - 99) * 3.6)), 30)     % loading circle
	    Draw.Arc (x, y, 24, 24, 90, round (90 + ((n - 99) * 3.6)), 30)
	    Draw.Arc (x, y, 25, 25, 90, round (90 + ((n - 99) * 3.6)), 30)
	    drawfillbox (48, 48, 162, 92, 12)
	    Draw.Text ("AMMO: " + intstr (gun (gunmodel).ammo), 180, 50, standfont, 12)
	    Draw.Text ("CLIP: " + intstr (gun (gunmodel).clip), 180, 80, standfont, 12)
	else
	    Draw.ThickLine (x + round (gun (gunmodel).acu * hyp) + 10, y, x + round (gun (gunmodel).acu * hyp) + 20, y, 2, 30)     %right
	    Draw.ThickLine (x - round (gun (gunmodel).acu * hyp) - 10, y, x - round (gun (gunmodel).acu * hyp) - 20, y, 2, 30)     %left
	    Draw.ThickLine (x, y + round (gun (gunmodel).acu * hyp) + 10, x, y + round (gun (gunmodel).acu * hyp) + 20, 2, 30)     %bottom
	    Draw.ThickLine (x, y - round (gun (gunmodel).acu * hyp) - 10, x, y - round (gun (gunmodel).acu * hyp) - 20, 2, 30)     %bottom
	    drawfillbox (48, 48, 162, 92, 30)
	    Draw.Text ("AMMO: " + intstr (gun (gunmodel).ammo), 180, 50, standfont, 30)
	    Draw.Text ("CLIP: " + intstr (gun (gunmodel).clip), 180, 80, standfont, 30)
	end if

	if gun (gunmodel).clip = gun (gunmodel).clipsize then
	    drawfillbox (48, 48, 162, 92, 10)
	    Draw.Text ("AMMO: " + intstr (gun (gunmodel).ammo), 180, 50, standfont, 10)
	    Draw.Text ("CLIP: " + intstr (gun (gunmodel).clip), 180, 80, standfont, 10)
	end if

	drawfillbox (50, 50, 160, 90, black)
	Pic.Draw (gun (gunmodel).pic, 50, 50, picMerge)

	Pic.Draw (buygunpic, 2546 + backx, 1346 + backy, picMerge)
	Pic.Draw (buypowerpic, 1776 + backx, 1346 + backy, picMerge)

	dontshoot := false
	GunMenu

	if Contact (round (bullet.x), round (bullet.y), 1756 + backx, 1326 + backy, 1868 + backx, 1415 + backy) = true then     %Upgrade buying
	    Draw.Text ("Press E to buy Upgrades ", 390, 400, standfont, white)
	    if switchtimer <= 0 and keys ('e') then
		if buypowermenu = false then
		    buypowermenu := true
		elsif buypowermenu = true then
		    buypowermenu := false
		end if
		switchtimer := 10
	    end if

	    if buypowermenu = true then
		drawfillbox (200, 100, 800, 300, grey)
	    end if
	else
	    buypowermenu := false
	end if

	View.Update
	delay (15)
    end loop
    for i : 1 .. znumber
	Sprite.Hide (zombie (i).sprite)
    end for
    %Death screen
    Draw.Text ("You Died :(", 100, 350, Font.New ("arial:30"), brightred)
    for i : 1 .. 179
	Sprite.ChangePic (bulletsprite, robullet (1) (i))
	delay (10)
    end for

    Sprite.Hide (bulletsprite)

    HS
end loop
