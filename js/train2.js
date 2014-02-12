/**
 * 
 */

var DEBUG = true;

Function.prototype.extend = function(parentClass) {
    if (parentClass.constructor == Function) {
        // Normal Inheritance
        this.prototype = new parentClass;
        this.prototype.constructor = this;
        this.prototype.parent = parentClass.prototype;
    }
    return this;
}

function Action() {
}
Action.prototype.run = function() {
    var steps = this.steps();
    for ( var i in steps) {
        log(i);
        if (this.interupt) return;
        if (this.finish) break;
        steps[i]();
    }

    return JSON.stringify(this.output);
}

function LoginAction(username, password, verifyCode) {
    this.input = {
        username : username,
        password : password,
        verifyCode : verifyCode
    };
    this.output = {};
}

LoginAction.extend(Action);
LoginAction.prototype.steps = function() {
    var input = this.input;
    var output = this.output;
    var action = this;
    return [ function() {
        log("login1");
        var response = http.sendRequest({
            "message" : "准备登录中...",
            "method" : "POST",
            "url" : "https://kyfw.12306.cn/otn/login/loginAysnSuggest",
            "referer" : "https://kyfw.12306.cn/otn/login/init",
            "data" : {
                "loginUserDTO.user_name" : input.username,
                "userDTO.password" : input.password,
                "randCode" : input.verifyCode,
                "form" : "loginEncForm"
            }
        });
        var result = JSON.parse(response);
        log(result);

        if (result.data.loginCheck == "Y") {
            output.code = 1;
        } else {
            output.code = 2;
            output.message = result.messages[0];
            action.finish = true;
        }
    }, function() {
        var html = http.sendRequest({
            "message" : "努力登录中...",
            "method" : "POST",
            "url" : "https://kyfw.12306.cn/otn/login/userLogin",
            "referer" : "https://kyfw.12306.cn/otn/login/init",
            "data" : {
                "_json_att" : ""
            }
        });
    }, function() {
        var html = http.sendRequest({
            "message" : "还在登录，请稍候...",
            "method" : "GET",
            "url" : "https://kyfw.12306.cn/otn/modifyUser/initQueryUserInfo"
        });
        log(html);
        var userForm = dom.selectNodeSet(html, "//form[@id='modifyUserForm']//input");

        var realName = dom.selectNodeText(userForm, "//input[@name='userDTO.loginUserDTO.name']/@value");
        var email = dom.selectNodeText(userForm, "//input[@name='userDTO.email']/@value");
        var mobile = dom.selectNodeText(userForm, "//input[@name='userDTO.mobile_no']/@value");
        var loginName = dom.selectNodeText(userForm, "//input[@name='userDTO.loginUserDTO.user_name']/@value");

        var m = String(userForm).match(/(is_active)(.+?)value/);
        log(m[0]);

        output.date = {
            "realName" : realName,
            "email" : email,
            "mobile" : mobile,
            "loginName" : loginName
        };
    } ];
};

function getLoginVerificationCode() {

    return http.getStream({
                                         "method" : "POST",
                                         "url" : "https://kyfw.12306.cn/otn/passcodeNew/getPassCodeNew?module=login&rand=sjrand",
                                         "data" : {
                                         }
                                         });
}

function login1(username, passowrd, verifyCode, listener) {
    var request = $.ajax({
        type : "POST",
        url : "https://kyfw.12306.cn/otn/login/loginAysnSuggest",
        headers : {
            referer : "https://kyfw.12306.cn/otn/login/init",
        },
        data : {
            "loginUserDTO.user_name" : username,
            "userDTO.password" : passowrd,
            "randCode" : verifyCode,
            "form" : "loginEncForm"
        }
    });
    request.done(function(data) {
        log(data);
        // listener.succeed({
        // status : "xxyyzz"
        // });
        login2(listener);
    });

}

function login2(listener) {

    var request = $.ajax({
        type : "POST",
        url : "https://kyfw.12306.cn/otn/login/userLogin",
        beforeSend : function(request) {
            request.setRequestHeader("referer", "https://kyfw.12306.cn/otn/login/init");
        },
        data : {
            "_json_att" : ""
        }
    });
    request.done(function(data) {
        log(data);
        login3(listener);
    });
}

function login3(listener) {

    var request = $.ajax({
        type : "GET",
        url : "https://kyfw.12306.cn/otn/modifyUser/initQueryUserInfo"
    });
    request.done(function(data) {
        // log(data);

        var userForm = dom.selectNodeSet(data, "//form[@id='modifyUserForm']//input");

        var realName = dom.selectNodeText(userForm, "//input[@name='userDTO.loginUserDTO.name']/@value");
        var email = dom.selectNodeText(userForm, "//input[@name='userDTO.email']/@value");
        var mobile = dom.selectNodeText(userForm, "//input[@name='userDTO.mobile_no']/@value");
        var loginName = dom.selectNodeText(userForm, "//input[@name='userDTO.loginUserDTO.user_name']/@value");

        listener.succeed({
            status : "xxyyzz"
        });
        // listener.success(null);
    });
}

function login(username, passowrd, verifyCode) {

    var request = JSON.stringify({
        "waitDesc" : "准备登录中...",
        "method" : "POST",
        "url" : "https://kyfw.12306.cn/otn/login/loginAysnSuggest",
        "referer" : "https://kyfw.12306.cn/otn/login/init",
        "data" : {
            "loginUserDTO.user_name" : username,
            "userDTO.password" : passowrd,
            "randCode" : verifyCode,
            "form" : "loginEncForm"
        }
    });

    var response = http.sendRequest(request);
    var result = JSON.parse(response);
    var errorMessage = result.messages[0];

    if (errorMessage != null) {
        return errorMessage;
    }

    var request = JSON.stringify({
        "waitDesc" : "努力登录中...",
        "method" : "POST",
        "url" : "https://kyfw.12306.cn/otn/login/userLogin",
        "referer" : "https://kyfw.12306.cn/otn/login/init",
        "data" : {
            "_json_att" : ""
        }
    });

    var html = http.sendRequest(request);
    // var loginName = dom.selectNodeText(html,
    // "//a[@id='login_user']/span/text()");

    var request = JSON.stringify({
        "waitDesc" : "还在登录，请稍候...",
        "method" : "GET",
        "url" : "https://kyfw.12306.cn/otn/modifyUser/initQueryUserInfo"
    });

    var html = http.sendRequest(request);
    var userForm = dom.selectNodeSet(html, "//form[@id='modifyUserForm']//input");

    var realName = dom.selectNodeText(userForm, "//input[@name='userDTO.loginUserDTO.name']/@value");
    var email = dom.selectNodeText(userForm, "//input[@name='userDTO.email']/@value");
    var mobile = dom.selectNodeText(userForm, "//input[@name='userDTO.mobile_no']/@value");
    var loginName = dom.selectNodeText(userForm, "//input[@name='userDTO.loginUserDTO.user_name']/@value");

    var m = String(userForm).match(/(is_active)(.+?)value/);
    log(m[0]);

    return JSON.stringify({
        "errorMessage" : errorMessage,
        "data" : {
            "realName" : realName,
            "email" : email,
            "mobile" : mobile,
            "loginName" : loginName
        }
    });
}

function queryTickets(from, to, date) {

    var response = http.sendRequest(JSON.stringify({
        "waitDesc11" : "正在搜索余票...",
        "method" : "GET",
        "url" : "https://kyfw.12306.cn/otn/leftTicket/query",
        "referer" : "https://kyfw.12306.cn/otn/leftTicket/init",
        "data" : {
            "leftTicketDTO.train_date" : date,
            "leftTicketDTO.from_station" : from,
            "leftTicketDTO.to_station" : to,
            "purpose_codes" : "ADULT"
        }
    }));

    return response;
}

function log(message) {
    if (DEBUG) {
        // console.log(message);
    }
}
