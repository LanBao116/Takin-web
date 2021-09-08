package io.shulie.takin.web.entrypoint.controller.scriptmanage;

import io.shulie.takin.common.beans.annotation.ModuleDef;
import io.shulie.takin.common.beans.page.PagingList;
import io.shulie.takin.web.biz.service.scriptmanage.ScriptDebugService;
import io.shulie.takin.web.common.constant.APIUrls;
import io.shulie.takin.web.biz.constant.BizOpConstants;
import io.shulie.takin.web.biz.pojo.request.scriptmanage.PageScriptDebugRequest;
import io.shulie.takin.web.biz.pojo.request.scriptmanage.PageScriptDebugRequestRequest;
import io.shulie.takin.web.biz.pojo.request.scriptmanage.ScriptDebugDoDebugRequest;
import io.shulie.takin.web.biz.pojo.response.scriptmanage.ScriptDebugDetailResponse;
import io.shulie.takin.web.biz.pojo.response.scriptmanage.ScriptDebugListResponse;
import io.shulie.takin.web.biz.pojo.response.scriptmanage.ScriptDebugRequestListResponse;
import io.shulie.takin.web.biz.pojo.response.scriptmanage.ScriptDebugResponse;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * 脚本调试表(ScriptDebug)表控制层
 *
 * @author liuchuan
 * @since 2021-05-10 17:12:03
 */
@RestController
@RequestMapping(APIUrls.TAKIN_API_URL + "scriptDebug/")
@Api(tags = "接口: 脚本调试")
public class ScriptDebugController {

    @Autowired
    private ScriptDebugService scriptDebugService;

    @ApiOperation("|_ 调试")
    @PostMapping("debug")
    @ModuleDef(moduleName = BizOpConstants.Modules.SCRIPT_MANAGE,
        subModuleName = BizOpConstants.SubModules.SCRIPT_MANAGE,
        logMsgKey = BizOpConstants.Message.SCRIPT_MANAGE_UPDATE)
    public ScriptDebugResponse debug(@Validated @RequestBody ScriptDebugDoDebugRequest request) {
        return scriptDebugService.debug(request);
    }

    @ApiOperation("|_ 调试详情")
    @ApiImplicitParams({
        @ApiImplicitParam(name = "scriptDebugId", value = "脚本调试记录id", required = true,
            dataType = "long", paramType = "query")
    })
    @GetMapping("detail")
    public ScriptDebugDetailResponse show(@RequestParam Long scriptDebugId) {
        return scriptDebugService.getById(scriptDebugId);
    }

    @ApiOperation("|_ 调试列表(分页)")
    @GetMapping("list")
    public PagingList<ScriptDebugListResponse> index(@Validated PageScriptDebugRequest pageScriptDebugRequest) {
        return scriptDebugService.pageFinishedByScriptDeployId(pageScriptDebugRequest);
    }

    @ApiOperation("|_ 调试的请求流量明细列表(分页)")
    @GetMapping("requestList")
    public PagingList<ScriptDebugRequestListResponse> requestList(@Validated PageScriptDebugRequestRequest pageScriptDebugRequestRequest) {
        return scriptDebugService.pageScriptDebugRequest(pageScriptDebugRequestRequest);
    }

}
