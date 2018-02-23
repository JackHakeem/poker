--
-- Author: shineflag
-- Date: 2017-11-29 10:35:48
--
-- 道具相关接口
return {

	["richdata.getprop"] = {  --获取用户道具信息

		req = {
			mid = 1234, --用户的mid
		},
		resp = {
			ret = 200,   -- -101获取信息失败 
			prop = {    --所有的道具信息  rid代表道具id  rid > 10  目前都为数字字符串(json编码原因)
				-- ["rid"] = num     --  11:参赛券(目前只有一种道具)
		    }
		}
	},
}