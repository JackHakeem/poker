local platformEventHalper = require("app.utils.platformEventHalper")

local FacebookHelper = {}

function FacebookHelper.shareOpenGraph(url,title,bmpPath)
	local params = platformEventHalper.cmds.shareOpenGraph
	params.args = {
		url=url,
		title=title,
		bmpPath=bmpPath,
	}
	local ok,ret = platformEventHalper.callEvent(params)
	if ok then 
		return true
	else
		return false,"shareOpenGraph fail"
	end
end

function FacebookHelper.appInvite(appLinkUrl,previewImageUrl)
	local params = platformEventHalper.cmds.fbAppInvite
	params.args = {
		appLinkUrl=appLinkUrl,
		previewImageUrl=previewImageUrl,
	}
	local ok,ret = platformEventHalper.callEvent(params)
	if ok then 
		return true
	else
		return false,"appInvite fail"
	end
end

function FacebookHelper.shareLink(url,msg)
	local params = platformEventHalper.cmds.shareLinkToFacebook
	params.args = {
		url=url,
		msg=msg or "",
	}
	local ok,ret = platformEventHalper.callEvent(params)
	if ok then 
		return true
	else
		return false,"shareLink fail"
	end
end

function FacebookHelper.getInvitableFriends()
	local params = platformEventHalper.cmds.fbGetInvitableFriends
	params.args = {
	}
	local ok,ret = platformEventHalper.callEvent(params)
	if ok then 
		if ret == "need login" then
			return false,"need login facebook"
		end
		return true
	else
		return false,"getInvitableFriends fail"
	end
end

function FacebookHelper.invitabelFriends(userIds,msg)
	userIds = checktable(userIds)
	local params = platformEventHalper.cmds.fbInvitabelFriends
	params.args = {
		to=table.concat(userIds,","),
		mid = tt.owner:getUid() .. "",
		msg = msg,
	}
	local ok,ret = platformEventHalper.callEvent(params)
	if ok then 
		return true
	else
		return false,"invitabelFriends fail"
	end
end

function FacebookHelper.getAllRequestsForReward()
	local params = platformEventHalper.cmds.fbGetAllRequestsForReward
	params.args = {
	}
	local ok,ret = platformEventHalper.callEvent(params)
	if ok then 
		return true
	else
		return false,"getAllRequestsForReward fail"
	end
end

return FacebookHelper



