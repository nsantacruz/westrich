package {
	//apparently i actually need all of these import statements which is weird. the reason, i think, is that flash doesn't import anything. if you want to use something,
	//you must import it
	import gs.TweenLite;
	import flash.display.*;
	import flash.text.*;
	import flash.events.*;
	public class Westrich_tl extends MovieClip {
		private var unitWidth;
		private var unitHeight;
		private var pages;            
		private var homePage;           
		private var portfolioPage;
		private var aboutPage;
		private var contactPage;
		private var invisibleBoxes;
		private var frameCounter;
		private var previousMenuX;
		private var currentMenuX;
		private var boxPositionsX;
		private var boxRows;
		private var row1;
		private var row2;
		private var row3;
		private var row4;
		private var row5;
		private var row6;
		private var row7;
		private var row8;
		private var currentPage;
		private var previousPage;
		private var menuHeights;
		private var invisiblePositionsX;
		public function Westrich_tl() {
			unitWidth=120;//unitBox width;
			unitHeight=75;//unitBox height;
			this.addEventListener("24",animateHomePage);//"this" refers to the timeline
			this.addEventListener("1",startListener);
			this.addEventListener("49",buildMenu);    //this eventListener makes the buttons visible only at frame 49
			invisibleBoxes=new Array(64);                  //this array holds all the boxes that are not being currently used by a page
			frameCounter=0;                                  
			previousMenuX=0;                                   //keeps track of the menu's previous x position so that the mask is kept in place (see onEnter())
			currentMenuX=0;                                            //the menu's current x
			boxPositionsX=[0,65,130,195,260,325,390,455,520];                 //this is a list of the x position's of how much box's should be moved when animating
			                                                                //basically, if you wanted to know how much 4 boxes in a row needed to be moverd you'd 
																			// write boxPositionsX[4] 
			menuHeights=[0,75,160,245,330,415,500,585,670];                 //a list of the different heights the menu should be, depending on how many rows need to
			                                                                //be shown
			invisiblePositionsX=[0,970,840,710,580,450,320,190,60];        //where a box should be moved so that it stays invisible. for example, box u14's position
			                                                               //can be accessed by writing invisiblePositionsX[1]. see onEnter()
			boxRows=new Array(8);                                         //a list containing all the rows on the stage
			pages=[homePage,portfolioPage,aboutPage,contactPage];        //an array of all the pages on the website. turns out i don't need it that much.
			homePage = new MovieClip();                                         
			portfolioPage = new MovieClip();
			aboutPage = new MovieClip();
			contactPage = new MovieClip();
			homePage.boxes=[];                                           //each page has this property which has a list of its boxes. used to distinguish between boxes
			                                                             //in use and invisible ones. this property is reset every time a page changes. see resetBoxes()
																		 //and getRows()
			portfolioPage.boxes=[];
			contactPage.boxes=[];
			aboutPage.boxes=[];
			homePage.rows=[];                            //this property is different than boxes since it isn't reset and contains a list of rows, which themselves 
			                                              //contain a list of boxes. used to know what rows need to be moved when animating. note that no matter how
														  //wide the page is, this will always contain whole rows, since it's important to move all the boxes in a row at once
			portfolioPage.rows=[];                
			aboutPage.rows=[];
			contactPage.rows=[];
			homePage.numWidth=6;                         //this is a number of how many boxes wide each page is
			portfolioPage.numWidth=8;
			aboutPage.numWidth=4;
			contactPage.numWidth=5;
			
			homePage.page = HomePage;
			aboutPage.page = AboutPage;
			portfolioPage.page = PortfolioPage;
			contactPage.page = ContactPage;
		}
		//this function is called on the 49th frame to set up the menu
		function buildMenu(e) {
			menu.portfolioButton.visible = true;          //first we need to make all the buttons visible (they were previously invisilbe, see startListener())
			menu.aboutButton.visible = true;
			menu.contactButton.visible = true;
			menu.portfolioButton.addEventListener(MouseEvent.CLICK,animatePortfolioPage); //and add all the mouseEvents to the buttons. I hope you know how this works
			menu.aboutButton.addEventListener(MouseEvent.CLICK,animateAboutPage);
			menu.contactButton.addEventListener(MouseEvent.CLICK,animateContactPage);
		}
		// this function will allow you to move anything anywhere on the x axis. useful...
		//notice the last two parameters of this function are null by default. this is a very useful trick i found online to add optional parameters to functions
		//unfortunately, i ended up making this pretty complicated and annoying. the basic idea is that i can chain functions together by running them through this function
		//now you ask, "why would you want to do that?" Well, Netanel, it's because I need the tweens in the dynamic animation to go one after another. for example, 
		//the animation needs to first move the menu into the right x position, then expand it so it is the right height and then move all the invisible boxes into place.
		//the problem is that many of these animations are a little complicated or are run through for loops. As you'll see, it is possible to chain tweens using the onComplete
		//property (see line 94) but since this is running within the function, there is no easy way to control what happens right after this tween. this is why i have these
		//two optional parameters. they serve as functions to run after the tween is done. each one is an array (this turned out to be really annoying, the reason i had to use
		//an array was because i found if i just wrote out the function as the parameter, it would run with this function, not after it since i was actually running the function
		//if i broke it up however, it wouldn't run right away) anyway, the first element of the array is the function name, the second is the first parameter for this function
		//and the third (if present) is the second parameter. this function accepts to functions so that i can chain three function in a row, namely moveToX(),menuGrow() and moveInvisibleBoxes()
		//see, that wasn't too bad
		function moveToX(X,element,funcArray = null,extraFuncArray = null) {
			menu.portfolioButton.mouseEnabled = false;         //i start out by not allowing you to press the buttons anymore while the animation is in progress
			menu.aboutButton.mouseEnabled = false;
			menu.contactButton.mouseEnabled = false;
			TweenLite.to(element,1,{x:(element.x+X),onComplete:moveFinish}); //this is why there's a folder required for the .swf. TweenLite is an external tween 
			                                                                 //engine that's very easy to use. the reason i didn't use Adobe's built in one is because
																			 //it kept on getting glitchy and messing up. much happier with TweenLite :)
			//this is the function that will run after this tween is done. as you can see, there are a few if statements in order to figure out what's null and 
			//what's not
			function moveFinish() {
				if (funcArray!=null&&extraFuncArray!=null&&extraFuncArray[2]!=null) {          
					funcArray[0](funcArray[1],[extraFuncArray[0],extraFuncArray[1],extraFuncArray[2]]);
				} else if (funcArray!=null&&extraFuncArray!=null) {
					funcArray[0](funcArray[1],[extraFuncArray[0],extraFuncArray[1]]);
				} else if (funcArray != null) {
					funcArray[0](funcArray[1]);
				}
			}
		}
		//this function moves whole rows at a time and is used to move previously invisible rows into place. it implements the same chaining process as moveToX()
		function moveRowTo(X,row,funcArray = null,extraFuncArray = null) {
			for (var i = 0; i < row.length; i++) {
				TweenLite.to(row[i],1,{x:(row[i].x+X),onComplete:moveFinish});
			}

			function moveFinish() {
				if (funcArray!=null&&extraFuncArray!=null&&funcArray[2]!=null) {
					funcArray[0](funcArray[1],funcArray[2],[extraFuncArray[0],extraFuncArray[1]]);
				} else if (funcArray!=null&&extraFuncArray!=null) {
					funcArray[0](funcArray[1],[extraFuncArray[0],extraFuncArray[1]]);
				} else if (funcArray != null) {
					funcArray[0](funcArray[1]);
				}
			}
		}
		//makes the menu whatever size you want. I made three parts to the menu: top, middel (spelled wrong), and bottom. i only need to change the middel's size,
		//everything else just needs to move.(check out the menu to see what i'm talking about)
		//also, at the end i call maskGrow() so the mask always stays the same height as the menu.
		
		//also implements chaining feature of moveToX(). the second stage in the dynamic animation
		function menuGrow(px,funcArray = null,extraFuncArray = null) {
			var middel=Math.abs(px-100);
			var deltaMiddel=middel-menu.middel.height;
			TweenLite.to(menu.middel,1,{height:middel,onComplete:growFinish});
			TweenLite.to(menu.top,1,{y:(menu.top.y-deltaMiddel/2)});
			TweenLite.to(menu.bottom,1,{y:(menu.bottom.y+deltaMiddel/2)});
			function growFinish() {
				if (funcArray!=null&&extraFuncArray!=null) {
					funcArray[0](funcArray[1],[extraFuncArray[0],extraFuncArray[1]]);
				} else if (funcArray != null&&funcArray[2] != null) {
					funcArray[0](funcArray[1],funcArray[2]);
				} else if (funcArray != null) {
					funcArray[0](funcArray[1]);
				}
			}
			maskGrow(px);
		}
		//the third and final stage of the animation. this moves the previously hidden boxes into place
		//in its moveFinish() function (run after the tween finishes) it makes the buttons work again and also set's the pages boxes (since now the page has finally
		//finished being animated)  see getRows() and reset() to see what happens when this is called
		function moveInvisibleBoxes(px) {
			for (var w = 0; w < invisibleBoxes.length; w++) {
				TweenLite.to(invisibleBoxes[w],1,{x:(invisibleBoxes[w].x + px),onComplete:moveFinish});
				function moveFinish() {
					currentPage.boxes = getRows(currentPage.rows.length);
					menu.portfolioButton.mouseEnabled = true;
					menu.aboutButton.mouseEnabled = true;
					menu.contactButton.mouseEnabled = true;
					
					currentPage.page.gotoAndStop(1);
					currentPage.page.visible = true;
					currentPage.page.play();
			    }
			}
			//since the for loop above won't run when there are no invisibleBoxes(namely, all the boxes are being displayed as in the portfolio page) you need to make
			//sure the finish function is run
			if (invisibleBoxes.length == 0) {
				currentPage.boxes = getRows(currentPage.rows.length);
				menu.portfolioButton.mouseEnabled = true;
				menu.aboutButton.mouseEnabled = true;
				menu.contactButton.mouseEnabled = true;
				
				currentPage.page.gotoAndStop(1);
				currentPage.page.visible = true;
				currentPage.page.play();
			}
			
		}
		
		//extraordinarily useful function. this thing accepts a start and end box. in this case, they must be of the same x position. it then creates an array of
		//the boxes in this range and returns it. look down at doneListener for its implementation. really cool stuff. i got help with this from actionscript.org
		//also, i take the boxes being used out of invisibleBoxes so that it only contains the invisible boxes.
		function getBoxesX(_start,_end) {
			var startNum:Number=Number(_start.name.charAt(2));
			var endNum:Number=Number(_end.name.charAt(2));
			var Xpos=Number(_start.name.charAt(1));
			var range=endNum-startNum;
			var array=[];
			var Ypos=startNum;
			for (var i = 0; i <= range; i++) {

				array.push(this["u" + Xpos + Ypos]);//this line is pure awesomeness. "this" refers to the timeline. in order to dynamically reference the boxes, they
				//to be a property of something, namely, the timeline. by using brackets, you can use concatenation to form the name of the box. B-)
				Ypos++;
			}
			return array;
		}
		//the y version of the previous function
		function getBoxesY(_start,_end) {
			var startNum:Number=Number(_start.name.charAt(1));
			var endNum:Number=Number(_end.name.charAt(1));
			var Ypos=Number(_start.name.charAt(2));
			var range=endNum-startNum;
			var array=[];
			var Xpos=startNum;
			for (var i = 0; i <= range; i++) {
				array.push(this["u" + Xpos + Ypos]);
				Xpos++;
			}
			//for (var j = 0; j<array.length;j++) {
			//trace(array[j].name);
			//}
			return array;
		}
		//this function is called at the first frame. the reason i needed this (it took me a while to figure out) is that apparently i can't reference anything on the
		//timeline until exactly the first frame. if i tried putting this in the constuctor, it would throw errors
		function startListener(e) {
			PortfolioPage.visible = false;
			ContactPage.visible = false;
			AboutPage.visible = false;
			
			menu.portfolioButton.visible = false;
			menu.aboutButton.visible = false;
			menu.contactButton.visible = false;
			//the order may look random but it's not. basically, this array
			//is used in the getRows() function in order to make pages. however, you only want
			//rows starting from the middle. that's why i start with rows 4 and 5. look at 
			//getRows() for more info on how this is used
			row4=getBoxesY(u14,u84);
			row5=getBoxesY(u15,u85);
			row3=getBoxesY(u13,u83);
			row6=getBoxesY(u16,u86);
			row2=getBoxesY(u12,u82);
			row7=getBoxesY(u17,u87);
			row1=getBoxesY(u11,u81);
			row8=getBoxesY(u18,u88);
			boxRows=[row4,row5,row3,row6,row2,row7,row1,row8];
			var counter=0;
			for (var k = 1; k <= 8; k++) {//get all the boxes on the stage and put them in this array
				for (var l = 1; l<=8; l++) {
					invisibleBoxes[counter]=this["u"+k+l];
					counter++;
				}
			}
			masker.visible=false;//for testing purposes
			//now i can finally set the rows that each page should contain since they've been initialized
			homePage.rows=[row4,row5,row3,row6];
			portfolioPage.rows=[row4,row5,row3,row6,row2,row7,row1,row8];
			aboutPage.rows=[row4,row5,row3,row6];
			contactPage.rows=[row4,row5,row3,row6,row2,row7];
			homePage.boxes=getRows(4);
			this.addEventListener(Event.ENTER_FRAME,onEnter);//this function is run every frame, a useful tool
		}
		function maskGrow(h) {
			TweenLite.to(masker,1,{height:h});
		}
		//this is called each frame.
		function onEnter(e) {
			//this is a class variable. if it's 0, we're at the first frame and nothing's happened yet so i need to initialize the variable
			if (frameCounter==0) {
				previousMenuX=menu.x;
			}
			//this is weird. if you can figure this out, that'd be great. for some reason, at frame 23, menu becomes null. after that it gets unnull. very strange.
			//this is to avoid errors
			if (menu==null) {
				return;
			}
			currentMenuX=menu.x;
			var deltaX=currentMenuX-previousMenuX;
			//i want to make sure all the invisible boxes stay to the left of the menu. this is what this does
			for (var n = 0; n < invisibleBoxes.length; n++) {
				var Xpos = Number(invisibleBoxes[n].name.charAt(1));
				invisibleBoxes[n].x = menu.x - invisiblePositionsX[Xpos];
			}
			//also, make sure the mask is exactly next to the the right side of the menu. works like a charm
			masker.width-=deltaX;
			previousMenuX=currentMenuX;
			frameCounter++;
		}
		//this is what separates the invisible boxes from the visible ones. since i need to keep track of what should be visible and what shouldn't, i need this
		//function
		function getRows(numRows) {
			resetBoxes();
			var array=[];
			for (var o = 0; o < numRows; o++) {
				array=array.concat(boxRows[o]);  //put all the boxes of each row into a big array
				for (var p = 0; p < boxRows[o].length; p++) {  //now loop through each row and delete every box that shouldn't be invisible from invisibleBoxes
					var index=invisibleBoxes.indexOf(boxRows[o][p]);
					if (index!=-1) {      //index is -1 if the box wasn't found. we only want to take out the boxes that exist in invisibleBoxes
						invisibleBoxes.splice(index,1);
					}
				}
			}

			return array;
		}

		function resetBoxes() {
			var counter=0;
			for (var k = 1; k <= 8; k++) {//get all the boxes on the stage and put them in this array
				for (var l = 1; l<=8; l++) {
					invisibleBoxes[counter]=this["u"+k+l];
					counter++;
				}
			}
			homePage.boxes=[];//make all pages null again
			portfolioPage.boxes=[];
			aboutPage.boxes=[];
			contactPage.boxes=[];
		}
		//this listener is triggered on the 74th frame. look there to see how it's done. basically, it makes a big array of all the boxes that make up the home page
		function animateHomePage(e) {
			//currentPage keeps track of the page you're on so that you can animate accordingly
			currentPage=homePage;
			for (var m = 0; m < homePage.boxes.length; m++) {  //move all the boxes in homePage.boxes into place
				moveToX(364,homePage.boxes[m]);
			}
			menu.portfolioButton.mouseEnabled = true;         //now make all the buttons work
			menu.aboutButton.mouseEnabled = true;
			menu.contactButton.mouseEnabled = true;
		}
		function animatePortfolioPage(e) {
			if (currentPage == portfolioPage) { //stops you from doing anything if you're already on this page
				return;
			}
			makePagesInvisible();
			previousPage=currentPage;
			currentPage=portfolioPage;
			dynamicallyAnimate();      //what does this do? i guess you'll find out
		}
		function animateAboutPage(e) {
			if (currentPage == aboutPage) {
				return;
			}
			makePagesInvisible();
			previousPage=currentPage;
			currentPage=aboutPage;
			dynamicallyAnimate();
		}
		function animateContactPage(e) {
			if (currentPage == contactPage) {
				return;
			}
			makePagesInvisible();
			previousPage=currentPage;
			currentPage=contactPage;
			dynamicallyAnimate();
		}
		//don't think i every used this but oh well. you pass specific dimensions and it'll tell you which boxes in this range are invisible (i.e. on the left side of
		//the menu bar). i won't go through this since the reverse() method (line 344) caused me lots of trouble and kept messing up the array
		function isInvisible(numWidth,numHeight) {
			var array=[];
			var invisibleArray=[];
			for (var o = 0; o < numHeight; o++) {
				var reversedArray=boxRows[o].reverse();
				var tempArray=[];
				for (var q = 0; q < numWidth; q++) {
					tempArray[q]=reversedArray[q];
				}
				array=array.concat(tempArray);
			}
			for (var r = 0; r < array.length; r++) {
				if (array[r].x<menu.x) {
					invisibleArray.push(array[r]);
				}
			}
			return invisibleArray;
		}
		//this function i did use however. you give it a row and how many boxes on that row you need and it'll tell you how many are invisible
		function invisibleInRow(row,numWidth) {
			var array=[];
			for (var i = 7; i >= (8 - numWidth); i--) {     //since we are interested in checking for invisibility from right to left and the boxes in rows are arranged
			                                                //from left to right, we need to start from the end and work backwards
				if (row[i].x<menu.x) {           //if it's invisible
					array.push(row[i]);
				}
			}
			return array.length;
		}
		//you give this function two pages and it'll tell you which rows they have in common so you know what you'll need to move. the rows in common only need to be 
		//moved slightly since they are already at least partially visible while the rows not in common must be moved more
		function rowsInCommon(page1,page2) {
			var array=[];
			for (var t = 0; t < page1.rows.length; t++) {
				if (page2.rows.indexOf(page1.rows[t])!=-1) { //if the row in page2 is also in page1...
					array.push(page1.rows[t]);
				}
			}
			return array;
		}
		//this is the grand finale. this controls the entire animation even though it's pretty short. in fact, the entire animation is only two lines (line 391 and 393)
		function dynamicallyAnimate() {
			var deltaBox=0;
			//figure out which rows this page has with the previous page
			var commonRows=rowsInCommon(currentPage,previousPage);
			//figure out how many invisible boxes there are (if any)
			var numInvisible=invisibleInRow(commonRows[0],currentPage.numWidth);
			if (numInvisible!=0) {   //if there are invisible boxes, we know we need to move more boxes out from invisibility
				deltaBox=numInvisible;
			} else {    //if not, this means we have too many boxes and need to move more to invisibility. note that this number will always be negative to signify 
			            //movement in the opposite direction
				deltaBox=currentPage.numWidth-previousPage.numWidth; 
			}
			for (var v = 0; v < commonRows.length; v++) {
				//(deltaBox/Math.abs(deltaBox)) <-- this line is just meant to preserve the sign of deltaBox and make sure we move the row to the right if there were
				//invisible boxes and to the left if there weren't
				moveRowTo(((deltaBox/Math.abs(deltaBox))*boxPositionsX[Math.abs(deltaBox)]),commonRows[v]);
			}
			//this was a really annoying line to write. the best way for you to understand it (as well as me) is to look at what each parameter does in moveToX
			//note that chaining is used here and you'll need to follow the function as it moves down the chain. see the long comment on moveToX for more on chaining
			moveToX((-deltaBox/Math.abs(deltaBox))*boxPositionsX[Math.abs(deltaBox)],menu,[menuGrow,menuHeights[currentPage.rows.length]],[moveInvisibleBoxes,boxPositionsX[currentPage.numWidth]*2]);
		}
		function makePagesInvisible() {
			HomePage.visible = false;
			PortfolioPage.visible = false;
			ContactPage.visible = false;
			AboutPage.visible = false;
		}
	}
}