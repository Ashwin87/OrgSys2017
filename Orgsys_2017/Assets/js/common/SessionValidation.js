$(document).ready(function () {
    var timeoutID;
    var isActive;

    function setup() {
        this.addEventListener("mousemove", resetTimer, false);
        this.addEventListener("mousedown", resetTimer, false);
        this.addEventListener("keypress", resetTimer, false);
        this.addEventListener("DOMMouseScroll", resetTimer, false);
        this.addEventListener("mousewheel", resetTimer, false);
        this.addEventListener("touchmove", resetTimer, false);
        this.addEventListener("MSPointerMove", resetTimer, false);

        startTimer();
    }
    setup();

    //user is inactive if they dont interact with window ever x ammount of time
    function startTimer() {
        timeoutID = window.setTimeout(goInactive, 45000);
    }

    function resetTimer(e) {
        window.clearTimeout(timeoutID);
        goActive();
    }

    function goInactive() {
        isActive = false;
        checkSession(false);
    }
    function goActive() {
        isActive = true;
        startTimer();
    }
    //Check if user is active every x ammount of time
    setInterval(SetActive, 60000);
    function SetActive() {
        if (isActive) {
            checkSession(true);
            BrowserInfoUpdate();
        } else {
            goInactive();
        }
    }

    function checkSession(isActive) {
        $.ajax({
            url: window.getApi + "/api/Session/SessionTracker/" + window.token + "/" + isActive,//check if session is still active
            type: "POST",
            async: false,
            statusCode: {
                401: function (data) {
                    window.location.replace("/Orgsys_Forms/Orgsys_Login.aspx?logout=" + data.responseText);
                    window.history.forward();
                    window.token = "";
                }
            }
        });
    }

    function BrowserInfoUpdate() {
        var findIP = new Promise(r => { var w = window, a = new (w.RTCPeerConnection || w.mozRTCPeerConnection || w.webkitRTCPeerConnection)({ iceServers: [] }), b = () => { }; a.createDataChannel(""); a.createOffer(c => a.setLocalDescription(c, b, b), b); a.onicecandidate = c => { try { c.candidate.candidate.match(/([0-9]{1,3}(\.[0-9]{1,3}){3}|[a-f0-9]{1,4}(:[a-f0-9]{1,4}){7})/g).forEach(r) } catch (e) { } } })

        findIP.then(ip =>
            $.ajax({
                url: window.getApi + "/api/Session/SessionBrowserInfoUpdate/" + window.token,
                type: "POST",
                cache: false,
                async: false,
                data: "=" + encodeURIComponent(JSON.stringify({ IPAddress: ip, Browser: bowser.name + '-' + bowser.version }))
            })).catch(e => console.error(e));
    }
});