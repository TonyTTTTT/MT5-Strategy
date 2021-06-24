# MT5-strategy
- The strategy file write in MQL5 language, and run on MT5 platform.
## 2021/5/23
- Initial this respository, currently develop the strategy "Script/actionByYesterdayTrend.mq5"

## 2021/6/24
- Learn two things
	- Basic usage of EA
	- How to close the "position"(持倉)
	
- Init the mon-1 strategy
	- find that if declare "ENUM_POSITION_TYPE var = NULL"; there will be a big problem when comparing(==)
	- two version, when inverse info. come
		- close
		- close and buy

