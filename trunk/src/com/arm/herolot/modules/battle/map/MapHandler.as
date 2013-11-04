package com.arm.herolot.modules.battle.map
{
	import flash.geom.Point;

	/**
	 * 对地图矩阵操作逻辑的封装
	 * @author lrf
	 */
	public class MapHandler
	{
		private var _matrixData:Vector.<Vector.<int>>;
		private var _rows:int;
		private var _cols:int;
		
		public function MapHandler(matrixData:Vector.<Vector.<int>> = null)
		{
			setMatrixData(matrixData);
		}
		
		public function setMatrixData(matrixData:Vector.<Vector.<int>>):void
		{
			_matrixData = matrixData;
			if(_matrixData)
			{
				_rows = matrixData.length;
				_cols = matrixData[0].length;
			}
		}
		
		public function checkStatus(row:int, col:int, status:int):Boolean
		{
			return ((_matrixData[row][col] & status) == status);
		}
		
		public function checkStatus_s(row:int, col:int, status:int):Boolean
		{
			return validate(row, col) && checkStatus(row, col, status);
		}
		
		public function setStatus(row:int, col:int, status:int):void
		{
			_matrixData[row][col] |= status;
		}
		
		public function setStatus_s(row:int, col:int, status:int):void
		{
			if(validate(row, col))
				setStatus(row, col, status);
		}
		
		public function unsetStatus(row:int, col:int, status:int):void
		{
			_matrixData[row][col] &= ~status;
 		}
		
		public function unsetStatus_s(row:int, col:int, status:int):void
		{
			if(validate(row, col))
				unsetStatus(row, col, status);
		}
		
		public function validate(row:int, col:int):Boolean
		{
			return (row >= 0 && row < _rows 
					&& col >= 0 && col < _cols);
		}
		
		public function checkAroundExist(row:int, col:int, status:int):Boolean
		{
			return (checkStatus_s(row - 1, col, status)
					||checkStatus_s(row + 1, col, status)
					||checkStatus_s(row, col - 1, status)
					||checkStatus_s(row, col + 1, status)
					||checkStatus_s(row - 1, col - 1, status)
					||checkStatus_s(row - 1, col + 1, status)
					||checkStatus_s(row + 1, col - 1, status)
					||checkStatus_s(row + 1, col + 1, status));
		}
		
		
		/*******************************************************************************************/
		
		public function setAroundOpenable(row:int, col:int):Vector.<Point>
		{
			var availableList:Vector.<Point> = new Vector.<Point>();
			
			checkCrossAvailable(row + 1, col);
			checkCrossAvailable(row - 1, col);
			checkCrossAvailable(row, col + 1);
			checkCrossAvailable(row, col - 1);
			
			function checkCrossAvailable(r:int, c:int):void
			{
				if (validate(r, c) && !(checkStatus(r, c, MapBuilder.GRID_STATUS_IS_OPENED)))
				{
					if (!isNearOpenedMonster(r, c))
					{
						setStatus(r, c, MapBuilder.GRID_STATUS_CAN_BE_OPENED);
						availableList.push(new Point(r, c));
					}
				}
			}
			return availableList;
		}
		
		public function setAroundOnMonsterDie(row:int, col:int):Object
		{
			var availableList:Vector.<Point> = new Vector.<Point>();
			var resetList:Vector.<Point> = new Vector.<Point>();
			
			recheckAvailable(row + 1, col);
			recheckAvailable(row - 1, col);
			recheckAvailable(row, col + 1);
			recheckAvailable(row, col - 1);
			
			recheckAvailable(row + 1, col + 1);
			recheckAvailable(row - 1, col - 1);
			recheckAvailable(row + 1, col - 1);
			recheckAvailable(row - 1, col + 1);
			
			return {availableList:availableList, resetList:resetList};
			
			function recheckAvailable(r:int, c:int):void
			{
				if (validate(r, c) && !(checkStatus(r, c, MapBuilder.GRID_STATUS_IS_OPENED)))
				{
					if (!isNearOpenedMonster(r, c))
					{
						if(canSetOpenable(r, c))
						{
							setStatus(r, c, MapBuilder.GRID_STATUS_CAN_BE_OPENED);
							availableList.push(new Point(r, c));
						}
						else
						{
							unsetStatus(r, c, MapBuilder.GRID_STATUS_CAN_BE_OPENED);
							resetList.push(new Point(r, c));
						}
					}
				}
			}
			
			function canSetOpenable(row:int, col:int):Boolean
			{
				if(checkStatus_s(row + 1, col, MapBuilder.GRID_STATUS_IS_OPENED)
					&& !checkStatus(row + 1, col, MapBuilder.GRID_STATUS_MONSTER))
				{
					return true;
				}
				
				if(checkStatus_s(row - 1, col, MapBuilder.GRID_STATUS_IS_OPENED)
					&& !checkStatus(row - 1, col, MapBuilder.GRID_STATUS_MONSTER))
				{
					return true;
				}
				
				if(checkStatus_s(row, col + 1, MapBuilder.GRID_STATUS_IS_OPENED)
					&& !checkStatus(row, col + 1, MapBuilder.GRID_STATUS_MONSTER))
				{
					return true;
				}
				
				if(checkStatus_s(row, col - 1, MapBuilder.GRID_STATUS_IS_OPENED)
					&& !checkStatus(row, col - 1, MapBuilder.GRID_STATUS_MONSTER))
				{
					return true;
				}
				return false;
			}
		}
		
		public function setAroundDisOpenable(row:int, col:int):Vector.<Point>
		{
			var disableList:Vector.<Point> = new Vector.<Point>();
			checkDisable(row + 1, col);
			checkDisable(row - 1, col);
			checkDisable(row, col + 1);
			checkDisable(row, col - 1);
			checkDisable(row + 1, col - 1);
			checkDisable(row - 1, col + 1);
			checkDisable(row + 1, col + 1);
			checkDisable(row - 1, col - 1);
			
			function checkDisable(r:int, c:int):void
			{
				if (validate(r, c) && !(checkStatus(r, c, MapBuilder.GRID_STATUS_IS_OPENED)))
				{
					unsetStatus(r, c, MapBuilder.GRID_STATUS_CAN_BE_OPENED);
					disableList.push(new Point(r, c));
				}
			}
			return disableList;
		}
		
		public function isNearOpenedMonster(row:int, col:int):Boolean
		{
			return checkAroundExist(row, col, MapBuilder.GRID_STATUS_MONSTER | MapBuilder.GRID_STATUS_IS_OPENED);
		}
		
		public function isOpenedMonster(row:int, col:int):Boolean
		{
			return checkStatus_s(row, col, MapBuilder.GRID_STATUS_MONSTER | MapBuilder.GRID_STATUS_IS_OPENED);
		}
		
		/*algorithm for bot*/
		public function getTouchableTile():Point
		{
			var i:int, j:int;
			for(i = 0; i < _rows; i++)
			{
				for(j = 0; j < _cols; j++)
				{
					if(checkStatus(i, j, MapBuilder.GRID_STATUS_CAN_BE_OPENED)
						||checkStatus(i, j, MapBuilder.GRID_STATUS_IS_OPENED | MapBuilder.GRID_STATUS_ITEM)
						||checkStatus(i, j, MapBuilder.GRID_STATUS_IS_OPENED | MapBuilder.GRID_STATUS_MONSTER))
						return new Point(i, j);
				}
			}
			return null;
		}
	}
}