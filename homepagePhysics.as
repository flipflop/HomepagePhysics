package {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import Box2D.Dynamics.*;
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.Joints.*;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.net.URLRequest;
	
	public class homepagePhysics extends Sprite {
		public var m_world:b2World;
		public var m_iterations:int = 10;
		public var m_timeStep:Number = 1/30;
		public var mousePVec:b2Vec2 = new b2Vec2();
		public var real_x_mouse:Number;
		public var real_y_mouse:Number;
		public var pixels_in_a_meter = 30;
		public var worldAABB:b2AABB = new b2AABB();
		public var gravity:b2Vec2 = new b2Vec2(0.0, 10.0);
		public var mouseJoint:b2MouseJoint;
		
		public function homepagePhysics() {
			
			url = "img/background.jpg";
			imageLoader = new Loader();
			thmbClip = new MovieClip();
			newImage = new URLRequest(url);
			imageLoader.load(newImage);
			addChild(imageLoader);
			
			addEventListener(Event.ENTER_FRAME, Update, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, on_mouse_down);
			stage.addEventListener(MouseEvent.MOUSE_UP, on_mouse_up);
			worldAABB.lowerBound.Set(-100.0, -100.0);
			worldAABB.upperBound.Set(100.0, 100.0);
			m_world = new b2World(worldAABB, gravity, true);
			var body:b2Body;
			var bodyDef:b2BodyDef;
			var boxDef:b2PolygonDef;
			
			var url:String; 
			var newImage:URLRequest;
			var imageLoader:Loader;
			var thmbClip:MovieClip;
			var ground_width = stage.stageWidth / 2 / pixels_in_a_meter;
			var ground_height = 0.5;
			var crate_width:Number = 1.5;
			var crate_height:Number = 1.5;
			
			bodyDef = new b2BodyDef();
			bodyDef.position.Set(ground_width, stage.stageHeight/30 + 0.5);
			boxDef = new b2PolygonDef();
			
			boxDef.SetAsBox(ground_width, ground_height);
			boxDef.friction = 0.3;
			boxDef.density = 0;
			bodyDef.userData = new floor();
			bodyDef.userData.width = stage.stageWidth;
			bodyDef.userData.height = 1;
			bodyDef.userData.alpha = 0;
			addChild(bodyDef.userData);
			
			body = m_world.CreateBody(bodyDef);
			body.CreateShape(boxDef);
			body.SetMassFromShapes();
			
			// --- left wall
			bodyDef = new b2BodyDef();
			bodyDef.position.x = -0.1;
			bodyDef.position.y = 0;
			
			boxDef = new b2PolygonDef();
			boxDef.SetAsBox(0.1, stage.stageHeight);
			boxDef.density = 0;
			boxDef.friction = 0.3;
			boxDef.restitution = 0;
			bodyDef.userData = new floor();
			bodyDef.userData.width = 0.1;
			bodyDef.userData.height = stage.stageHeight;
			bodyDef.userData.alpha = 0;
			body = m_world.CreateBody(bodyDef);
			body.CreateShape(boxDef);
			//body.SetMassFromShapes();
			addChild(bodyDef.userData);
			
			// ---- right wall
			
			bodyDef = new b2BodyDef();
			bodyDef.position.x = ground_width * 2 + 0.1;
			bodyDef.position.y = 0;
			
			boxDef = new b2PolygonDef();
			boxDef.SetAsBox(0.1, stage.stageHeight);
			boxDef.density = 0;
			boxDef.friction = 0.3;
			boxDef.restitution = 0;
			bodyDef.userData = new floor();
			bodyDef.userData.width = 0.1;
			bodyDef.userData.height = stage.stageHeight;
			bodyDef.userData.alpha = 0;
			body = m_world.CreateBody(bodyDef);
			body.CreateShape(boxDef);
			//body.SetMassFromShapes();
			addChild(bodyDef.userData);
			
			// ---
						
			for (var i:int = 1; i <=6; i++) {
				url = "img/thmb_"+i+".jpg";
				imageLoader = new Loader();
				thmbClip = new MovieClip();
				newImage = new URLRequest(url);
				imageLoader.load(newImage);
				
				thmbClip.addChild(imageLoader);
				thmbClip.x = -49;
				thmbClip.y = -50;
				
				bodyDef = new b2BodyDef();
				bodyDef.position.x = Math.random() * 15 + 1;
				bodyDef.position.y = Math.random();
				
				boxDef = new b2PolygonDef();
				boxDef.SetAsBox(crate_width, crate_height);
				boxDef.density = 1.5;
				boxDef.friction = 0.5;
				boxDef.restitution = 0.2;
				bodyDef.userData = new crate();
				
				bodyDef.userData.width = crate_width * 2 * pixels_in_a_meter;
				bodyDef.userData.height = crate_height * 2* pixels_in_a_meter;
				body = m_world.CreateBody(bodyDef);
				body.CreateShape(boxDef);
				body.SetMassFromShapes();
				bodyDef.userData.addChild(thmbClip);
				addChild(bodyDef.userData);
			}
			
			// ---- top wall
			
			bodyDef = new b2BodyDef();
			bodyDef.position.x = 0;
			bodyDef.position.y = 0;
			
			boxDef = new b2PolygonDef();
			boxDef.SetAsBox(stage.stageWidth, 0.1);
			boxDef.density = 0;
			boxDef.friction = 0.3;
			boxDef.restitution = 0;
			bodyDef.userData = new floor();
			bodyDef.userData.width = stage.stageHeight;
			bodyDef.userData.height = 0.1;
			bodyDef.userData.alpha = 0;
			body = m_world.CreateBody(bodyDef);
			body.CreateShape(boxDef);
			//body.SetMassFromShapes();
			addChild(bodyDef.userData);
		}
		public function Update(e:Event):void {
			m_world.Step(m_timeStep, m_iterations);
			if (mouseJoint) {
				var mouseXWorldPhys = mouseX/pixels_in_a_meter;
				var mouseYWorldPhys = mouseY/pixels_in_a_meter;
				var p2:b2Vec2 = new b2Vec2(mouseXWorldPhys, mouseYWorldPhys);
				mouseJoint.SetTarget(p2);
			}
			for (var bb:b2Body = m_world.m_bodyList; bb; bb = bb.m_next) {
				if (bb.m_userData is Sprite) {
					bb.m_userData.x = bb.GetPosition().x * pixels_in_a_meter;
					bb.m_userData.y = bb.GetPosition().y * pixels_in_a_meter;
					bb.m_userData.rotation = bb.GetAngle() * (180/Math.PI);
				}
			}
		}
		public function on_mouse_down(evt:MouseEvent):void {
			var body:b2Body = GetBodyAtMouse();
			if (body) {
				var mouse_joint:b2MouseJointDef = new b2MouseJointDef;
				mouse_joint.body1 = m_world.GetGroundBody();
				mouse_joint.body2 = body;
				mouse_joint.target.Set(mouseX/pixels_in_a_meter, mouseY/pixels_in_a_meter);
				mouse_joint.maxForce = 10000;
				mouse_joint.timeStep = m_timeStep;
				mouseJoint = m_world.CreateJoint(mouse_joint) as b2MouseJoint;
			}
		}
		public function on_mouse_up(evt:MouseEvent):void {
			if (mouseJoint) {
				m_world.DestroyJoint(mouseJoint);
				mouseJoint = null;
			}
		}
		public function GetBodyAtMouse(includeStatic:Boolean=false):b2Body {
			real_x_mouse = (stage.mouseX)/pixels_in_a_meter;
			real_y_mouse = (stage.mouseY)/pixels_in_a_meter;
			mousePVec.Set(real_x_mouse, real_y_mouse);
			
			var aabb:b2AABB = new b2AABB();
			aabb.lowerBound.Set(real_x_mouse - 0.001, real_y_mouse - 0.001);
			aabb.upperBound.Set(real_x_mouse + 0.001, real_y_mouse + 0.001);
			var k_maxCount:int = 10;
			var shapes:Array = new Array();
			var count:int = m_world.Query(aabb, shapes, k_maxCount);
			var body:b2Body = null;
			for (var i:int = 0; i < count; ++i) {
				if (shapes[i].m_body.IsStatic() == false || includeStatic) {
					var tShape:b2Shape = shapes[i] as b2Shape;
					var inside:Boolean = tShape.TestPoint(tShape.m_body.GetXForm(), mousePVec);
					if (inside) {
						body = tShape.m_body;
						break;
					}
				}
			}
			return body;
		}
	}
}