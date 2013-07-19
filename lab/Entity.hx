package lab;
	
class Entity {

	public var _components : Map<String, Entity>;
    public var id : String;
    public var name : String;

	public function new(){
		id = lab.utils.UUID.get();
		_components = new Map();
	}

	public function add<T>(type:Class<T>, ?_name:String='') : T {
		
		if(_name == '') {
			name = Lab.utils.uuid();
		} else {
			name = _name;
		}		

			//create an instance
		var _component = Type.createInstance( type, [] );
			//store it in the component list
		_components.set(name, cast _component);

		return _component;
	}

	public function get(_name:String, ?in_children:Bool = false, ?first_only:Bool = true ) : Dynamic {
		
		if(!in_children) {

			return _components.get(_name);

		} else {

			var results = [];

			var is_this_component = _components.get(_name);
			if(is_this_component != null) {
				if(first_only) {
					return is_this_component;
				} else {
					results.push(is_this_component);	
				} //first only
			} //is_this_component

				//check each of our child components for this named item
			for(_component in _components) {				
				var found : Dynamic = _component.get( _name, true, first_only );
				if(found != null) {
						//early out
					if(first_only) return found;
						//store otherwise
					if(Std.is(found, Array)) {
						results.concat(found);
					} else {
						results.push(found);
					}
				} //found != null
			} //each component

			return (results.length > 0) ? results : null;
		}

		return null;
	}

	public function has(name:String) : Bool {
		return _components.exists(name);
	}

	private function _call(_object:Entity, _name:String, ?args) {
		var _func = Reflect.field(_object, _name);
		if(_func != null) {
			Reflect.callMethod(_object, _func, args );
		} //init function exists?
	}

	public function _init() {
			//update the parent first
		_call(this, 'init');

		for(_component in _components) {
			_call(_component, 'init');
		} //for each component
	} //_init

	public function _destroy() {
			//update the parent first
		_call(this, 'destroy');

		for(_component in _components) {
			_call(_component, 'destroy');
		} //for each component
	} //_destroy

	public function _start() {
			//update the parent first
		_call(this, 'start');

		for(_component in _components) {
			_call(_component, 'start');
		} //for each component
	} //_start

	public function _update(dt:Float) {
			//update the parent first
		_call(this, 'update', [dt]);

		for(_component in _components) {
			_call(_component, 'update', [dt]);
		} //for each component
	} //_update


}