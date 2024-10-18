<template>
    <div>
        <div
            class="footer"
            v-if="status || version"
        >
            <div
                class="footer__status"
                :class="[`footer__status-${statusId}`]"
                title="Обновить обработку"
                v-if="status"
                @click="sendCommand('addon_status_version')"
            >
               {{status}}
            </div>
            <div
                class="footer__version"
                :class="[`footer__version-${statusId}`]"
                v-if="version"
                @click="sendCommand('addon_version')"
            >
                {{version}}
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
        margin: String
    },
    data() {
        return {
            status: null,
            version: null,
            statusId: '0'
        }
    },
    mounted() {
        window.updateFooter = footerData => {
            const footerConfig = Connector._decode(footerData)
            this.updateFooter(footerConfig)
        }
        // Без setTimeout 1с не успевают перехватить событие
        setTimeout(() => {
            Connector.readSystemInfo(footerConfig => this.updateFooter(footerConfig))
        }, 0)
    },
    methods: {
        updateFooter([status, version, colorId]) {
            this.status = status || null
            this.version = version || null
            this.statusId = colorId
        },
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
