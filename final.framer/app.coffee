# Import file "framer" (sizes and positions are scaled 1:2)
sketch = Framer.Importer.load("imported/framer@2x")
Framer.Device.background.style.background = "#000"

ios = require "ios-kit"
data = JSON.parse Utils.domLoadDataSync "data/data.json"
Framer.Extras.Hints.disable()

Utils.insertCSS('@font-face {font-family: "CothamSans";src: url("fonts/CothamSans.otf") format("opentype");}')

Framer.Defaults.Animation =
	curve: "spring(250, 25, 0)"
	
Framer.Info =
	title: "Discussions app"
	description: ""
	author: "Sergey Voronov"
	twitter: "mamezito"
global=new Layer
	size:Screen.size
	backgroundColor: "#F2F2F2"
# sketch.discussions.visible=false
sketch.filteractive.visible=false
sketch.filter.y=55
sketch.filter1.opacity=0
sketch.filter1.onClick (event, layer) ->
# 	if scrolls[1].scrollPoint.y==0
	scrolls[1].animate
		y:sketch.filter.height
	sketch.filter.animate
		y: 127
		
	sketch.filteractive.visible=true
sketch.filteractive.onClick (event, layer) ->
	if scrolls[1].y>0
		scrolls[1].animate
				y:0
	sketch.filteractive.visible=false
	sketch.filter.animate
		y: 55
# <<< Framer Fold <<<



page=new PageComponent
	size:Screen.size
	directionLock:true
	parent:global
	scrollVertical: false
scrolls=[]
for i in [0...2]
	
	scroll=new ScrollComponent
		size:page.size
		superLayer: page.content
		scrollHorizontal: false
		x:i*Screen.width
		directionLock:true
		contentInset:
			top: 128
			bottom: 98
	scrolls.push(scroll)
	scroll.content=backgroundColor: "null"
	if i==1
		sketch.discussions.superLayer=scroll.content
		scroll.contentInset=
			top: 128
			bottom:68
# page.content.backgroundColor= "null"
sketch.filter.superLayer=global
sketch.navbar.superLayer=global
sketch.tabbar.superLayer=global
sketch.statusbar.superLayer=global
# sketch.discussions.superLayer=page.content




#discussions
gapV=0
gapH=0
channelHeight=240
covers=[]
channels=[]
for channel,i in data.channels
	cat=new Layer
		x:gapH
		width:Screen.width-gapH*2
		height:channelHeight
		y:channelHeight*i
		superLayer: scrolls[0].content
		borderRadius: 0
		backgroundColor: "black"
		clip:true
		
	cover=new Layer
		width:cat.width
		height:400
		superLayer: cat	
		image: channel.image
		opacity:0.6
		borderRadius: cat.borderRadius
	title = new ios.Text
		text:channel.name
		fontSize:25
		fontWeight:600
		superLayer:cat
		color:"#ADADAD"
		constraints:
			top:80
			leading:40
		fontFamily:"CothamSans"
	
	plus=new Layer
		image:"images/plus.png"
		size:32
		y:6
		x:-50
		name:"plus"
		superLayer: title
	check=new Layer
		image:"images/checkbox.png"
		size:32
		name:"check"
		visible:false
		y:6
		x:-50
		superLayer: title
	title.states.checked=
		color:"white"
	
	usersCount=new ios.Text
		text:channel.members
		fontSize:17
		fontWeight:300
		superLayer:cat
		color:"white"		
		constraints:
			top:83
			trailing:20
	usersIcon=new Layer
		image:"images/users.png"
		size:32
		x:-40
		y:4
		opacity:0.8
		superLayer: usersCount
	postCount=new ios.Text
		text:channel.discussions
		fontSize:17
		fontWeight:300
		superLayer:cat
		color:"white"
		
	postIcon=new Layer
		image:"images/discussions.png"
		width:28
		height:24
		opacity:0.8
		x:-40
		y:8
		superLayer: postCount
	postCount.maxX=usersCount.x-60
	postCount.y=usersCount.y
	
	title.onClick (event, layer) ->
		
		if this.states.current.name=="default"
			this.stateSwitch("checked")
			this.childrenWithName("check")[0].visible=true
			this.childrenWithName("plus")[0].visible=false
		else
			this.stateSwitch("default")
			this.childrenWithName("check")[0].visible=false
			this.childrenWithName("plus")[0].visible=true
			
		
	channels.push(cat)
	covers.push(cover)
scrolls[0].onMove ->
	for channel,i in channels
# 		print channel
		covers[i].y=Utils.modulate(channel.screenFrame.y,[0,Screen.height],[0,-200],true)
	
page.on "change:currentPage", ->
	if page.horizontalPageIndex(page.currentPage)==0
		if scrolls[1].y>0
			scrolls[1].animate
					y:0
		sketch.filteractive.visible=false
		sketch.filter.animate
			y: 55
		sketch.filter1.animate
			opacity:0
		sketch.filter1.ignoreEvents=true
		whiteBubble.animate("default")
		discussionsTitle.ignoreEvents=false
		channelsTitle.ignoreEvents=true
		discussionsTitle.color="#9B9B9B"
		channelsTitle.color="#595AD3"
	
	else
		sketch.filter1.animate
			opacity:1
		sketch.filter1.ignoreEvents=false
		whiteBubble.animate("second")
		discussionsTitle.ignoreEvents=true
		channelsTitle.ignoreEvents=false
		discussionsTitle.color="#595AD3"
		channelsTitle.color="#9B9B9B"

#buttongroup
channelsTitle = new ios.Text
	text:"Channels"
	fontSize:14
	fontWeight:600	
	color:"#595AD3"
	y:19
discussionsTitle = new ios.Text
	text:"Discussions"
	fontSize:14
	fontWeight:300	
	color:"#9B9B9B"
	y:19

greyBubble=new Layer
	width:channelsTitle.width+discussionsTitle.width+120+6
	height:64
	backgroundColor: "D8D8D8"
	borderRadius: 64
	x:Align.center
	y:54
channelsTitle.superLayer=greyBubble
discussionsTitle.superLayer=greyBubble
channelsTitle.x=33
discussionsTitle.x=channelsTitle.maxX+60
whiteBubble=new Layer
	superLayer: greyBubble
	x:3
	y:3
	backgroundColor: "white"
	borderRadius: 64
	height:greyBubble.height-6
	width:channelsTitle.width+60
whiteBubble.sendToBack()
whiteBubble.states.second=
	width:discussionsTitle.width+60
	x:discussionsTitle.x-30
whiteBubble.animationOptions=
		curve: "spring"
discussionsTitle.onClick (event, layer) ->	
	whiteBubble.animate("second")
	discussionsTitle.ignoreEvents=true
	channelsTitle.ignoreEvents=false
	discussionsTitle.color="#595AD3"
	discussionsTitle.style.fontWeight=600
	channelsTitle.style.fontWeight=300
	channelsTitle.color="#9B9B9B"
	page.snapToNextPage()
channelsTitle.onClick (event, layer) ->	
	whiteBubble.animate("default")
	discussionsTitle.style.fontWeight=300
	channelsTitle.style.fontWeight=600
	discussionsTitle.ignoreEvents=false
	channelsTitle.ignoreEvents=true
	discussionsTitle.color="#9B9B9B"
	channelsTitle.color="#595AD3"
	page.snapToPreviousPage()