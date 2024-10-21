function noop() {}

class Connector {
    initConnector() {
        const sendDomElem = document.createElement('div');
        window.domConnector = {
            sendDomElem,
            request: {}
        };
        window.resolve = this._onResolve.bind(this)
        sendDomElem.setAttribute('style', 'display: none');
        sendDomElem.setAttribute('id', 'toExtSys');
        document.body.appendChild(sendDomElem);
        return window.domConnector;
    }

    _call(objName, method, data, cb = noop) {
        let connector = window.domConnector;
        if (!connector) {
            connector = this.initConnector();
        }
        if (!connector.sendDomElem) {
            connector = this.initConnector();
        }
        connector.request = {
            objName,
            method,
            data,
            callback: cb
        };
        try {
            connector.request.data = data.toString()
            this._send(connector, connector.request)
        } catch (err) {
            alert(`error send ${err.message}`);
        }
    }

    _send(connector, request) {
        try {
            request.action = `${request.objName}_${request.method}`.toUpperCase();
            connector.sendDomElem.setAttribute('action', request.action);
            connector.sendDomElem.textContext = request.data;
            connector.sendDomElem.click();
        } catch (err) {
            throw err
        }
    }

    _onResolve(data) {
        const connector = window.domConnector;
        const result = this._decode(data)
        connector.request.callback(result)
    }

    _decode(data) {
        try {
            return data.split(';')
        } catch (err) {
            alert(`Decode error ${err.message}`)
        }
    }

    navigate(id, cb = noop) {
        this._call(
            'Addon',
            'navigate',
            id,
            cb
        );
    }

    click(id, cb = noop) {
        this._call(
            'Addon',
            'click',
            id,
            cb
        );
    }

    readSystemInfo(cb) {
        this._call(
            'Addon',
            'readSystemInfo',
            '',
            cb
        );
    }
}

export default new Connector()
