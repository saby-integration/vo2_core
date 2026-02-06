<template>
    <div>
        <div
            class="footer"
            v-if="clientVersionStatusMessage || productVersionStatus?.currentVersionNumber"
        >
            <div
                class="footer__status"
                :class="[`footer__status-${productVersionStatus.clientVersionStatus}`]"
                title="Обновить обработку"
                v-if="clientVersionStatusMessage"
                @click="sendCommand('addon_status_version')"
            >
               {{clientVersionStatusMessage}}
            </div>
            <div
                class="footer__version"
                :class="[`footer__version-${productVersionStatus.clientVersionStatus}`]"
                v-if="productVersionStatus.currentVersionNumber"
                @click="sendCommand('addon_version')"
            >
                {{productVersionStatus.currentVersionNumber}}
            </div>
        </div>
        <div v-else></div>
    </div>
</template>

<script>
import Connector from "../../core/Connector";

export default {
    name: "AccordionFooter",
    props: {
      productVersionStatus: Object
    },
    data() {
        return {}
    },
    computed: {
      clientVersionStatusMessage() {
        const clientVersionStatusMessageMap = {
          1: 'Стабильная',
          2: 'Доступно обновление',
          3: 'Версия устарела',
          4: 'Версия сильно устарела!',
        }
        return clientVersionStatusMessageMap[this.productVersionStatus?.clientVersionStatus]
      }
    },
    methods: {
        sendCommand(id) {
            Connector.click(id)
        }
    }
}
</script>

<style>
.footer {
    display: flex;
    display: -webkit-flex;
    flex-direction: column;
    -webkit-flex-direction: column;
    justify-content: flex-end;
    -webkit-justify-content: flex-end;
    margin: 8px 0 10px 12px;
}
.footer__version {
    margin-top: 4px;
}
.footer__status {
    text-decoration: none;
}
.footer__version-5,
.footer__version-1 {
    color: #8991a9;
}
.footer__status-1 {
    color: #2562AA
}
.footer__status-1:hover {
    color: #153f6f
}
.footer__status-2,
.footer__status-3,
.footer__status-4,
.footer__version-2,
.footer__version-3,
.footer__version-4 {
    color: #C2140A;
}
.footer__status-2:hover,
.footer__status-3:hover,
.footer__status-4:hover {
    color: #E50C00;
}
.footer__status-3,
.footer__version-3,
.footer__status-4,
.footer__version-4 {
    font-size: 14px;
}
.footer__status-3,
.footer__status-4 {
    font-weight: bold;
}
.footer__status:hover {
    text-decoration: underline;
}
.footer__version, .footer__status {
    cursor: pointer;
}
</style>
