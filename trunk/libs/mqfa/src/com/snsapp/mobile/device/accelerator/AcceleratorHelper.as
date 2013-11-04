package com.snsapp.mobile.device.accelerator
{
	import flash.events.AccelerometerEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.sensors.Accelerometer;
	import flash.utils.getTimer;

	public class AcceleratorHelper extends EventDispatcher
	{
        /**
         * 检测为摇晃的加速度阀值 
         */        
        public static const A_THRESHOLD:Number = 1.6;
        
		public static var ShakeEnable:Boolean = true;

		/**加速计**/
		protected var _acc:Accelerometer;
		/**上次摇晃的时间**/
		protected var _lastShake:int;

		protected static var _instance:AcceleratorHelper;
        /**
         * 摇晃时间 
         */        
		protected static const SHAKE_DELAY:int = 2000;

		public static const Shake:String = "AcceleratorHelper_Shake";

		public function AcceleratorHelper(target:IEventDispatcher = null)
		{
			super(target);
			if (Accelerometer.isSupported)
			{
				_acc = new Accelerometer();
				_acc.addEventListener(AccelerometerEvent.UPDATE, onAccelerometer);
			}
		}

		public static function get instance():AcceleratorHelper
		{
			if (_instance == null)
				_instance = new AcceleratorHelper();
			return _instance;
		}

		public static function get isSupported():Boolean
		{
			return Accelerometer.isSupported;
		}

		protected function onAccelerometer(e:AccelerometerEvent):void
		{
			if (!ShakeEnable)
				return;

            var isShake:Boolean =
                Math.abs(e.accelerationX) >= A_THRESHOLD ||
                Math.abs(e.accelerationY) >= A_THRESHOLD ||
                Math.abs(e.accelerationZ) >= A_THRESHOLD;
			if (getTimer() - _lastShake > SHAKE_DELAY && isShake)
			{
				this.dispatchEvent(new Event(Shake));
				_lastShake = getTimer();
			}
		}
        
        
        /**
         * 模拟摇一摇，测试用 
         * 
         */        
        public function mockShape():void
        {
            /*var evt:AccelerometerEvent = 
                new AccelerometerEvent(
                    AccelerometerEvent.UPDATE, false, false, 0,
                    A_THRESHOLD + 1, A_THRESHOLD + 1, A_THRESHOLD + 1
                )
            
            _acc.dispatchEvent(evt);*/
            
            
            if (getTimer() - _lastShake > SHAKE_DELAY)
            {
                this.dispatchEvent(new Event(Shake));
                _lastShake = getTimer();
            }
        }
	}
}
