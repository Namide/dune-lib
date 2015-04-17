package dl.samples;

import flash.display.Sprite;

/**
 *
 * Sample: Mario Galaxy Gravity
 * Author: Luca Deltodesco
 *
 * Demonstrating applying impulses to Bodies
 * and use of the distance methods available through the
 * Geom object.
 *
 * Also demonstrates the use of MarchingSquares, convex
 * decompositions and polygon simplification.
 */
 
import nape.geom.AABB;
import nape.geom.Geom;
import nape.geom.IsoFunction;
import nape.geom.MarchingSquares;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Circle;
import nape.shape.Polygon;
import nape.space.Broadphase;
 
// Template
// https://github.com/deltaluca/www.napephys.com/search?utf8=✓&q=Template

import flash.display.StageQuality;
import flash.display.Sprite;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.Event;
import flash.system.System;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.Lib;

import nape.space.Space;
import nape.space.Broadphase;
import nape.phys.Body;
import nape.phys.BodyList;
import nape.phys.BodyType;
import nape.shape.Polygon;
import nape.geom.Vec2;
import nape.util.Debug;
import nape.util.BitmapDebug;
import nape.util.ShapeDebug;
import nape.constraint.PivotJoint;



// Template class is used so that this sample may
// be as concise as possible in showing Nape features without
// any of the boilerplate that makes up the sample interfaces.


class Nape extends Template {
    function new() {
        super({
            generator: generateObject
        });
    }
 
    var planetaryBodies:Array<Body>;
    var samplePoint:Body;
 
    override function init() {
        var w = stage.stageWidth;
        var h = stage.stageHeight;
 
        var border = createBorder();
 
        // We want to find for each body, the closest point on the planet to the bodys
        // centre of mass. Geom provides us with a method distanceBody which finds the
        // distance between two bodies and closest points, so if we create a Body having
        // only a very small circle in it, and position it at the body centre of mass
        // we can get the closest point to the centre of mass.
        //
        // In future, Nape may implement an automatic way of doing this for an arbitrary
        // point; perhaps simply using this trick internally.
        samplePoint = new Body();
        samplePoint.shapes.add(new Circle(0.001));
 
        // make the border a planet too!
        planetaryBodies = [border];
 
        // Create the central planet.
        var planet = new Body(BodyType.STATIC);
        var polys = MarchingSquares.run(
            new StarIso(),
            new AABB(0, 0, w, h),
            new Vec2(5, 5)
        );
        for (poly in polys) {
            var convexPolys = poly.simplify(1).convexDecomposition(true);
            for (p in convexPolys) {
                planet.shapes.add(new Polygon(p));
            }
        }
        planet.space = space;
        planetaryBodies.push(planet);
 
        // Create additional planets
        // Platform in top right
        planet = new Body(BodyType.STATIC);
        planet.position.setxy(680, 120);
        planet.rotation = Math.PI/4;
        planet.shapes.add(new Polygon(Polygon.box(100, 1)));
        planet.space = space;
        planetaryBodies.push(planet);
 
        // Box in bottom right
        planet = new Body(BodyType.STATIC);
        planet.position.setxy(680, 480);
        planet.rotation = Math.PI/4;
        planet.shapes.add(new Polygon(Polygon.box(80, 80)));
        planet.space = space;
        planetaryBodies.push(planet);
 
        // Triangle in bottom left
        planet = new Body(BodyType.STATIC);
        planet.position.setxy(120, 480);
        planet.rotation = -Math.PI/4;
        planet.shapes.add(new Polygon(Polygon.regular(50, 50, 3)));
        planet.space = space;
        planetaryBodies.push(planet);
 
        // Pentagon in bottom left
        planet = new Body(BodyType.STATIC);
        planet.position.setxy(120, 120);
        planet.rotation = Math.PI/4;
        planet.shapes.add(new Polygon(Polygon.regular(50, 50, 5)));
        planet.space = space;
        planetaryBodies.push(planet);
 
        // Generate some random objects!
        for (i in 0...180) {
            var body = new Body();
 
            // Add random one of either a Circle, Box or Pentagon.
            if (Math.random() < 0.33) {
                body.shapes.add(new Circle(10));
            }
            else if (Math.random() < 0.5) {
                body.shapes.add(new Polygon(Polygon.box(20, 20)));
            }
            else {
                body.shapes.add(new Polygon(Polygon.regular(10, 10, 5)));
            }
 
            var angle = Math.PI * 2 / 60 * i;
            var radius = 200 + 25 * Std.int(i / 60);
            body.position.x = 400 + radius * Math.cos(angle);
            body.position.y = 300 + radius * Math.sin(angle);
            body.space = space;
        }
    }
 
    override function preStep(deltaTime:Float) {
        for (planet in planetaryBodies) {
            planetaryGravity(planet, deltaTime);
        }
    }
 
    function planetaryGravity(planet:Body, deltaTime:Float) {
        // Apply a gravitational impulse to all bodies
        // pulling them to the closest point of a planetary body.
        //
        // Because this is a constantly applied impulse, whose value depends
        // only on the positions of the objects, we can set the 'sleepable'
        // of applyImpulse to be true and permit these bodies to still go to
        // sleep.
        //
        // Applying a 'sleepable' impulse to a sleeping Body has no effect
        // so we may as well simply iterate over the non-sleeping bodies.
        var closestA = Vec2.get();
        var closestB = Vec2.get();
 
        for (body in space.liveBodies) {
            // Find closest points between bodies.
            samplePoint.position.set(body.position);
            var distance = Geom.distanceBody(planet, samplePoint, closestA, closestB);
 
            // Cut gravity off, well before distance threshold.
            if (distance > 100) {
                continue;
            }
 
            // Gravitational force.
            var force = closestA.sub(body.position, true);
 
            // We don't use a true description of gravity, as it doesn't 'play' as nice.
            force.length = body.mass * 1e6 / (distance * distance);
 
            // Impulse to be applied = force * deltaTime
            body.applyImpulse(
                /*impulse*/ force.muleq(deltaTime),
                /*position*/ null, // implies body.position
                /*sleepable*/ true
            );
        }
 
        closestA.dispose();
        closestB.dispose();
    }
 
    function generateObject(pos:Vec2) {
        var body = new Body();
        body.position = pos;
 
        // Add random one of either a Circle, Box or Pentagon.
        if (Math.random() < 0.33) {
            body.shapes.add(new Circle(10));
        }
        else if (Math.random() < 0.5) {
            body.shapes.add(new Polygon(Polygon.box(20, 20)));
        }
        else {
            body.shapes.add(new Polygon(Polygon.regular(10, 10, 5)));
        }
 
        body.space = space;
    }
 
    static function main() {
        flash.Lib.current.addChild(new Nape());
    }
}
 
class StarIso implements IsoFunction {
    public function new() {}
    public function iso(x:Float, y:Float) {
        x -= 400;
        y -= 300;
        return 7000 * Math.sin(5 * Math.atan2(y, x)) + x * x + y * y - 150*150;
    }
}


// Template
// https://github.com/deltaluca/www.napephys.com/search?utf8=✓&q=Template

typedef TemplateParams = {
    ?gravity : Vec2,
    ?shapeDebug : Bool,
    ?broadphase : Broadphase,
    ?noSpace : Bool,
    ?noHand : Bool,
    ?staticClick : Vec2->Void,
    ?generator : Vec2->Void,
    ?variableStep : Bool,
    ?noReset : Bool,
    ?velIterations : Int,
    ?posIterations : Int,
    ?customDraw : Bool
};

class Template extends Sprite {

    var space:Space;
    var debug:Debug;
    var hand:PivotJoint;

    var variableStep:Bool;
    var prevTime:Int;

    var smoothFps:Float = -1;
    public var textField:TextField;
    var baseMemory:Float;

    var velIterations:Int = 10;
    var posIterations:Int = 10;
    var customDraw:Bool = false;

    var params:TemplateParams;
    var useHand:Bool;
    function new(params:TemplateParams) {
        baseMemory = System.totalMemoryNumber;
        super();

        if (params.velIterations != null) {
            velIterations = params.velIterations;
        }
        if (params.posIterations != null) {
            posIterations = params.posIterations;
        }
        if (params.customDraw != null) {
            customDraw = params.customDraw;
        }

        this.params = params;
        if (stage != null) {
            start(null);
        }
        else {
           addEventListener(Event.ADDED_TO_STAGE, start);
        }
    }

    function start(ev) {
        if (ev != null) {
            removeEventListener(Event.ADDED_TO_STAGE, start);
        }

        if (params.noSpace == null || !params.noSpace) {
            space = new Space(params.gravity, params.broadphase);

            if (useHand = (params.noHand == null || !params.noHand)) {
                hand = new PivotJoint(space.world, null, Vec2.weak(), Vec2.weak());
                hand.active = false;
                hand.stiff = false;
                hand.maxForce = 1e5;
                hand.space = space;
                stage.addEventListener(MouseEvent.MOUSE_UP, handMouseUp);
            }
            stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
        }

        if (params.noReset == null || !params.noReset) {
            stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
            stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
        }

        if (params.shapeDebug == null || !params.shapeDebug) {
            debug = new BitmapDebug(stage.stageWidth, stage.stageHeight, stage.color);
        }
        else {
            debug = new ShapeDebug(stage.stageWidth, stage.stageHeight, stage.color);
            stage.quality = StageQuality.LOW;
        }

        debug.drawConstraints = true;
        addChild(debug.display);

        variableStep = (params.variableStep != null && params.variableStep);
        prevTime = Lib.getTimer();
        addEventListener(Event.ENTER_FRAME, enterFrame);

        init();

        textField = new TextField();
        textField.defaultTextFormat = new TextFormat("Arial", null, 0xffffff);
        textField.selectable = false;
        textField.width = 128;
        textField.height = 800;
        addChild(textField);
    }

    function random() return Math.random();

    function createBorder() {
        var border = new Body(BodyType.STATIC);
        border.shapes.add(new Polygon(Polygon.rect(0, 0, -2, stage.stageHeight)));
        border.shapes.add(new Polygon(Polygon.rect(0, 0, stage.stageWidth, -2)));
        border.shapes.add(new Polygon(Polygon.rect(stage.stageWidth, 0, 2, stage.stageHeight)));
        border.shapes.add(new Polygon(Polygon.rect(0, stage.stageHeight, stage.stageWidth, 2)));
        border.space = space;
        border.debugDraw = false;
        return border;
    }

    // to be overriden
    function init() {}
    function preStep(deltaTime:Float) {}
    function postUpdate(deltaTime:Float) {}

    var resetted = false;
    function keyUp(ev:KeyboardEvent) {
        // 'r'
        if (ev.keyCode == 82) {
            resetted = false;
        }
    }
    function keyDown(ev:KeyboardEvent) {
        // 'r'
        if (ev.keyCode == 82 && !resetted) {
            resetted = true;
            if (space != null) {
                space.clear();
                if (hand != null) {
                    hand.active = false;
                    hand.space = space;
                }
            }
            System.pauseForGCIfCollectionImminent(0);
            init();
        }
    }

    var bodyList:BodyList = null;
    function mouseDown(_) {
        var mp = Vec2.get(mouseX, mouseY);
        if (useHand) {
            // re-use the same list each time.
            bodyList = space.bodiesUnderPoint(mp, null, bodyList);

            for (body in bodyList) {
                if (body.isDynamic()) {
                    hand.body2 = body;
                    hand.anchor2 = body.worldPointToLocal(mp, true);
                    hand.active = true;
                    break;
                }
            }

            if (bodyList.empty()) {
                if (params.generator != null) {
                    params.generator(mp);
                }
            }
            else if (!hand.active) {
                if (params.staticClick != null) {
                    params.staticClick(mp);
                }
            }

            // recycle nodes.
            bodyList.clear();
        }
        else {
            if (params.generator != null) {
                params.generator(mp);
            }
        }
        mp.dispose();
    }

    function handMouseUp(_) {
        hand.active = false;
    }

    function enterFrame(_) {
        var curTime = Lib.getTimer();
        var deltaTime:Float = (curTime - prevTime);
        if (deltaTime == 0) {
            return;
        }

        var fps = (1000 / deltaTime);
        smoothFps = (smoothFps == -1 ? fps : (smoothFps * 0.97) + (fps * 0.03));
        var text = "fps: " + ((""+smoothFps).substr(0, 5)) + "\n" +
                   "mem: " + ((""+(System.totalMemoryNumber - baseMemory) / (1024 * 1024)).substr(0, 5)) + "Mb";
        if (space != null) {
            text += "\n\n"+
                    "velocity-iterations: " + velIterations + "\n" +
                    "position-iterations: " + posIterations + "\n";
        }
        textField.text = text;

        if (hand != null && hand.active) {
            hand.anchor1.setxy(mouseX, mouseY);
            hand.body2.angularVel *= 0.9;
        }

        var noStepsNeeded = false;

        if (variableStep) {
            if (deltaTime > (1000 / 30)) {
                deltaTime = (1000 / 30);
            }

            debug.clear();

            preStep(deltaTime * 0.001);
            if (space != null) {
                space.step(deltaTime * 0.001, velIterations, posIterations);
            }
            prevTime = curTime;
        }
        else {
            var stepSize = (1000 / stage.frameRate);
            stepSize = 1000/60;
            var steps = Math.round(deltaTime / stepSize);

            var delta = Math.round(deltaTime - (steps * stepSize));
            prevTime = (curTime - delta);
            if (steps > 4) {
                steps = 4;
            }
            deltaTime = stepSize * steps;

            if (steps == 0) {
                noStepsNeeded = true;
            }
            else {
                debug.clear();
            }

            while (steps-- > 0) {
                preStep(stepSize * 0.001);
                if (space != null) {
                    space.step(stepSize * 0.001, velIterations, posIterations);
                }
            }
        }

        if (space != null && !customDraw && !noStepsNeeded) {
            debug.draw(space);
        }
        if (!noStepsNeeded) {
            postUpdate(deltaTime * 0.001);
            debug.flush();
        }
    }
}

