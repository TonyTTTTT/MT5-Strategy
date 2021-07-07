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
	- three version, when inverse info. come
		- close
		- close and ordering at same trend
		- close and buy

## 2021/6/25
- Refactor EA mon-1's code

## 2021/6/26
- set tp(take profit) and sl(stop loss)
- try to get the history deals data, but fail

## 2021/6/29
- success get history order, and add new condition
- don't order if already tp or sl in same trend

## 2021/7/5
- complete the baseline of mon-4

## 2021/7/7
- new version that inverse the logic of mon-4

