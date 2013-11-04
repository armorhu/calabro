package com.arm.herolot.modules.battle.battle.buff.implement
{
	import com.arm.herolot.modules.battle.battle.BattleEntity;
	import com.arm.herolot.modules.battle.battle.round.BattleRound;
	import com.arm.herolot.modules.battle.battle.buff.Buffer;
	import com.arm.herolot.services.utils.GameMath;

	/**
	 * 支持在任何时刻为改变宿主属性&战斗时为目标改变属性的buffer。
	 * @author hufan
	 */
	public class EnhanceCapacityBuffer extends Buffer
	{
		static public const ADDED_TO_OWNER:String = 'add';
		static public const REMOVED_FROM_OWNER:String = 'remove';
		static public const BEFORE_ATTACK:String = 'ba';
		static public const AFTER_ATTACK:String = 'aa';
		static public const BEFORE_INJURED:String = 'bi';
		static public const AFTER_INJURED:String = 'ai';
		/**肯定要执行的命令列表**/
		protected var _cmds:Object;
		/**攻击回合计划命令列表**/
		protected var _attackPlanList:Array;
		/**被攻击回合的计划命令列表**/
		protected var _injuredPlanList:Array;

		public function EnhanceCapacityBuffer()
		{
			_attackPlanList = new Array();
			_injuredPlanList = new Array();
			_cmds = new Array();
		}

		/**
		 * 几回合后，在什么阶段执行什么命令
		 */
		protected function addPlanAt(round:int, step:String, planCmd:String):void
		{
			if (step == BEFORE_ATTACK || step == AFTER_ATTACK)
			{
				if (round >= _attackPlanList.length)
					_attackPlanList.length = round;
				if (_attackPlanList[round] == null)
					_attackPlanList[round] = new Object();
				addPlan(_attackPlanList[round], step, planCmd);
			}
			else if (step == BEFORE_INJURED || step == AFTER_INJURED)
			{
				if (round >= _injuredPlanList.length)
					_injuredPlanList.length = round;
				if (_injuredPlanList[round] == null)
					_injuredPlanList[round] = new Object();
				addPlan(_injuredPlanList[round], step, planCmd);
			}
		}

		private function addPlan(plan:Object, step:String, planCmd:String):void
		{
			var stepCmds:Array = plan[step] as Array;
			if (stepCmds == null)
			{
				stepCmds = new Array();
				plan[step] = stepCmds;
			}
			stepCmds.push(planCmd);
		}

		/**被添加到宿主身上.step:add**/
		override protected function addedToOwner():void
		{
			tryExcuteCmds(ADDED_TO_OWNER, null, null);
		}

		/**从宿主身上移除.step:remove**/
		override protected function removedFromOwner():void
		{
			tryExcuteCmds(REMOVED_FROM_OWNER, null, null);
		}

//		/**
//		 * 攻击之前. step:ba
//		 */
//		override public function before_attack(target:BattleEntity, result:BattleResult):void
//		{
//			tryExcuteCmds(BEFORE_ATTACK, target, result);
//		}
//
//		/**
//		 * 攻击之后,step:aa;
//		 */
//		override public function after_attack(target:BattleEntity, result:BattleResult):void
//		{
//			tryExcuteCmds(AFTER_ATTACK, target, result);
//			if (_attackPlanList.length > 0)
//				_attackPlanList.shift(); //删除第一个元素。
//		}
//
//		/**
//		 * 被攻击之前,step:bi
//		 */
//		override public function before_injured(damager:BattleEntity, result:BattleResult):void
//		{
//			tryExcuteCmds(BEFORE_INJURED, damager, result);
//		}
//
//		/**
//		 * 被攻击之后,step:bi
//		 */
//		override public function after_injured(damager:BattleEntity, result:BattleResult):void
//		{
//			tryExcuteCmds(AFTER_INJURED, damager, result);
//			if (_injuredPlanList.length > 0)
//				_injuredPlanList.shift(); //删除第一个元素。
//		}

		/**
		 * 回合开始。
		 * 注意：一个回合通常只有ba->aa或者bi->ai.
		 *      不会出现其他情况
		 * **/
		private function roundBegin():void
		{
		}

		override public function setParams(params:Object):void
		{
			_cmds = params;
		}

		private function tryExcuteCmds(step:String, t:BattleEntity, result:BattleRound):void
		{
			//执行固有命令
			if (_cmds && _cmds[step])
				excuteCmds(_cmds[step], owner, t, result);
			//执行计划命令
			if (step == BEFORE_ATTACK || step == AFTER_ATTACK)
			{
				if (_attackPlanList.length > 0 && _attackPlanList[0])
					excuteCmds(_attackPlanList[0][step], owner, t, result);
			}
			else if (step == BEFORE_INJURED || step == AFTER_INJURED)
			{
				if (_injuredPlanList.length > 0 && _injuredPlanList[0])
					excuteCmds(_injuredPlanList[0][step], owner, t, result);
			}
		}

		protected function excuteCmds(cmdObj:Object, o:BattleEntity, t:BattleEntity, result:Object):void
		{
			if (cmdObj is String)
				excuteCmd(cmdObj as String);
			else if (cmdObj is Array)
				for (var i:int = 0, len:int = cmdObj.length; i < len; i++)
					excuteCmd(cmdObj[i] as String);


			function excuteCmd(cmd:String):void
			{
				var subCmds:Array = String(cmd).split(',');
				const len:int = subCmds.length;
				var type:int = -1, bool:Boolean;
				for (var i:int = 0; i < len; i++)
				{
					type = getExpressionType(subCmds[i]);
					if (type == Decision)
					{
						bool = isTrue(subCmds[i], o, t);
						if (bool)
						{
//							trace(subCmds[i], 'is true');
						}
						else
						{
//							trace(subCmds[i], 'is false');
							break;
						}
					}
					else if (type == Assignment)
					{
						trace('excuteMathCmd:', subCmds[i]);
						excuteMathCmd(subCmds[i], o, t, result);
					}
					else if (type == Plan)
					{
						var params:Array = String(subCmds[i]).split('|');
						trace('addPlan(', params, ')');
						addPlanAt(params[0], params[1], params[2]);
					}
				}
			}
		}


		public static const UNKNOWN:int = -1;
		public static const Assignment:int = 0;
		public static const Decision:int = 1;
		public static const Plan:int = 2;
		private static const AssignmentFlags:Array = ['+=', '-=', '*=', '/=', '='];
		private static const DecisionFlags:Array = ['==', '!=', '>=', '>', '<=', '<'];

		public static function getExpressionType(logicExpression:String):int
		{
			if (logicExpression.split('|').length == 3)
				return Plan;
			if (!isNaN(parseFloat(logicExpression)))
				return Decision;
			for (i = 0, len = DecisionFlags.length; i < len; i++)
				if (logicExpression.indexOf(DecisionFlags[i]) != -1)
					return Decision;
			for (var i:int = 0, len:int = AssignmentFlags.length; i < len; i++)
				if (logicExpression.indexOf(AssignmentFlags[i]) != -1)
					return Assignment;
			return UNKNOWN;
		}

		/**
		 * @param logicExpression
		 * @return
		 */
		public static function isTrue(logicExpression:String, o:BattleEntity, t:BattleEntity):Boolean
		{
			if (!isNaN(parseFloat(logicExpression)))
				return GameMath.random(parseFloat(logicExpression));

			logicExpression = logicExpression.replace(/ /g, ''); //去掉命令中的所有空格。
			var tempSplits:Array, compareFlag:String;
			for (var i:int = 0; i < DecisionFlags.length; i++)
			{
				if (logicExpression.indexOf(DecisionFlags[i]) != -1)
				{
					compareFlag = DecisionFlags[i];
					tempSplits = logicExpression.split(compareFlag);
					break;
				}
			}
			if (tempSplits && tempSplits.length != 2)
				throw new Error(logicExpression + '必须有且仅有一个逻辑判断符号[' + DecisionFlags.length + ']!');
			var leftExpression:String = tempSplits[0];
			var rightExpression:String = tempSplits[1];
			if (compareFlag == '==')
				return excutePlusExpression(leftExpression, o, t, null) == excutePlusExpression(rightExpression, o, t, null);
			else if (compareFlag == '!=')
				return excutePlusExpression(leftExpression, o, t, null) != excutePlusExpression(rightExpression, o, t, null);
			else if (compareFlag == '>=')
				return excutePlusExpression(leftExpression, o, t, null) >= excutePlusExpression(rightExpression, o, t, null);
			else if (compareFlag == '>')
				return excutePlusExpression(leftExpression, o, t, null) > excutePlusExpression(rightExpression, o, t, null);
			else if (compareFlag == '<=')
				return excutePlusExpression(leftExpression, o, t, null) <= excutePlusExpression(rightExpression, o, t, null);
			else if (compareFlag == '<')
				return excutePlusExpression(leftExpression, o, t, null) < excutePlusExpression(rightExpression, o, t, null);
			return false;
		}

		public static function excuteMathCmd(cmd:String, o:BattleEntity, t:BattleEntity, result:Object):void
		{
			cmd = cmd.replace(/ /g, ''); //去掉命令中的所有空格。
			var computeExpression:String; //计算表达式
			var resultExpression:String; //结果表达式

			var tempSplits:Array, equatFlag:String;
			for (var i:int = 0; i < AssignmentFlags.length; i++)
			{
				if (cmd.indexOf(AssignmentFlags[i]) != -1)
				{
					equatFlag = AssignmentFlags[i];
					tempSplits = cmd.split(AssignmentFlags[i]);
					break;
				}
			}

			if (tempSplits && tempSplits.length != 2)
				throw new Error(cmd + '必须有且仅有一个等式分隔符号（=、+=、-=、*=、/=）!');
			resultExpression = tempSplits[0];
			computeExpression = tempSplits[1];

			//解析结果表达式
			var resultProxy:BattleEntityPropertyProxy = new BattleEntityPropertyProxy(resultExpression, o, t);
			//解析计算表达式
			if (equatFlag == '+=')
				resultProxy.value += excutePlusExpression(computeExpression, o, t, result);
			else if (equatFlag == '-=')
				resultProxy.value -= excutePlusExpression(computeExpression, o, t, result);
			else if (equatFlag == '*=')
				resultProxy.value *= excutePlusExpression(computeExpression, o, t, result);
			else if (equatFlag == '/=')
				resultProxy.value /= excutePlusExpression(computeExpression, o, t, result);
			else if (equatFlag == '=')
				resultProxy.value = excutePlusExpression(computeExpression, o, t, result);
		}

		/**
		 * 执行加法表达式
		 */
		private static function excutePlusExpression(expression:String, o:BattleEntity, t:BattleEntity, result:Object):Number
		{
			expression = expression.replace(/\-/g, "+-"); //将表达式中的每一个减号前面都加上一个加号
			var tempSplits:Array = expression.split('+'); //然后用+号把整个表达式分割成若干部分。
			if (tempSplits.length == 0)
				throw new Error('计算表达式:[' + expression + ']不能为空!');
			var computeResult:Number = 0; //计算结果；
			var crtExpression:String;
			for (var i:int = 0; i < tempSplits.length; i++)
			{
				crtExpression = tempSplits[i] as String;
				if (crtExpression == '') //跳过空的项。
					continue;
				if (crtExpression.indexOf('*') != -1)
				{ //是乘法表达式。
					computeResult += excuteMultiExpression(crtExpression, o, t, result);
				}
				else
				{
					var num:Number = parseFloat(crtExpression);
					if (isNaN(num))
					{ //不是数字，也不是乘法表达式。。只能是属性代理了！
						computeResult += new BattleEntityPropertyProxy(crtExpression, o, t).value;
					}
					else
					{ //
						computeResult += num;
					}
				}
			}
			return computeResult;
		}

		/**
		 * 执行乘法表达式
		 */
		private static function excuteMultiExpression(expression:String, o:BattleEntity, t:BattleEntity, result:Object):Number
		{
			var tempSplits:Array = expression.split('*'); //然后用+号把整个表达式分割成若干部分。
			if (tempSplits.length == 0)
				throw new Error('计算表达式:[' + expression + ']不能为空!');
			var computeResult:Number = 1; //计算结果；
			var crtExpression:String;
			for (var i:int = 0; i < tempSplits.length; i++)
			{
				crtExpression = tempSplits[i] as String;
				var num:Number = parseFloat(crtExpression);
				if (isNaN(num))
				{ //不是数字，也不是乘法表达式。。只能是属性代理了！
					computeResult *= new BattleEntityPropertyProxy(crtExpression, o, t).value;
				}
				else
				{ //
					computeResult *= num;
				}
			}
			return computeResult;
		}
	}
}
import com.arm.herolot.modules.battle.battle.BattleEntity;


class BattleEntityPropertyProxy
{
	private var _target:Object;
	private var _property:String;

	public function BattleEntityPropertyProxy(expression:String, o:BattleEntity, t:BattleEntity)
	{
		var tempSplits:Array = expression.split('.');
//		if (tempSplits.length < 2)
//			throw new Error('属性代理表达式[' + expression + ']必须有且仅有一个"."!');
		/**表达式的开头必须是t或者o**/
		if (tempSplits[0] == 't')
			_target = t;
		else if (tempSplits[0] == 'o')
			_target = o;
		else
		{ //第一个元素没有指定battle对象，那默认是onwer对象。
			tempSplits.unshift('o');
			_target = o;
		}
		if (_target == null)
			throw new Error('无法解析对象：' + expression);
		if (tempSplits.length > 2)
			for (var i:int = 1; i < tempSplits.length - 1; i++)
			{
				_target = _target[tempSplits[i]];
				if (_target == null)
					throw new Error('无法解析对象：' + expression);
			}
		_property = tempSplits[tempSplits.length - 1];
		if (!_target.hasOwnProperty(_property) || !(_target[_property] is Number))
			throw new Error('属性代理表达式[' + expression + ']中结果属性[' + _property + ']不存在或不是Number类型');
	}

	public function get value():Number
	{
		return _target[_property];
	}

	public function set value(num:Number):void
	{
		_target[_property] = num;
	}
}
