<template>
    <div class="accordion-footer">
        <div
            v-if="userSettingsDisabled"
            class="accordion-footer__user-settings"
            :class="{'accordion-footer__user-settings_dark': isDarkTheme}"
        >
            <p class="accordion-footer__user-settings-message">Используются настройки по умолчанию, пользовательские настройки отключены</p>
            <button
                type="button"
                class="accordion-footer__user-settings-enable"
                @click="sendCommand('enable_user_settings')"
            >Включить</button>
        </div>
        <div
            class="accordion-footer__version-info"
            v-if="clientVersionStatusMessage || productVersionStatus?.currentVersionNumber"
        >
            <div
                class="accordion-footer__status"
                :class="[
                    `accordion-footer__status-${productVersionStatus.clientVersionStatus}`
                ]"
                title="Обновить обработку"
                v-if="clientVersionStatusMessage"
                @click="sendCommand('addon_status_version')"
            >
               {{clientVersionStatusMessage}}
            </div>
            <div
                class="accordion-footer__version"
                :class="[
                      `accordion-footer__version-${productVersionStatus.clientVersionStatus}`,
                      isDarkTheme && 'text-white'
                    ]"
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
      productVersionStatus: Object,
      userSettingsDisabled: Boolean
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
      },
      isDarkTheme() {
        return window.accordion?.theme === 'dark'
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
.accordion-footer {
    flex-shrink: 0;
    -webkit-flex-shrink: 0;
}
.accordion-footer__user-settings {
    margin: 8px 8px 12px 8px;
    padding: 6px 8px;
    border: 1px solid #F88F62;
    border-radius: 10px;
    color: #000;
    cursor: pointer;
}
.accordion-footer__user-settings:hover {
    background-color: #FFF1EB;
}
.accordion-footer__user-settings_dark {
    color: #fff;
}
.accordion-footer__user-settings_dark:hover {
    background-color: rgba(248, 143, 98, 0.15);
}
.accordion-footer__user-settings-message {
    margin-bottom: 4px;
    font-size: 11px;
    line-height: normal;
}
.accordion-footer__user-settings-enable {
    display: block;
    padding: 0;
    border: 0;
    background: transparent;
    color: #CC3D00;
    font-family: inherit;
    font-size: 14px;
    line-height: normal;
    text-align: left;
    cursor: pointer;
}
.accordion-footer__user-settings:hover .accordion-footer__user-settings-enable {
    text-decoration: underline;
}
.accordion-footer__version-info {
    display: flex;
    display: -webkit-flex;
    flex-direction: column;
    -webkit-flex-direction: column;
    justify-content: flex-end;
    -webkit-justify-content: flex-end;
    margin: 8px 0 10px 12px;
}
.accordion-footer__version {
    margin-top: 4px;
}
.accordion-footer__status {
    text-decoration: none;
}
.accordion-footer__version-5,
.accordion-footer__version-1 {
    color: #8991a9;
}
.accordion-footer__status-1 {
    color: #2562AA
}
.accordion-footer__status-1:hover {
    color: #153f6f
}
.accordion-footer__status-2,
.accordion-footer__status-3,
.accordion-footer__status-4,
.accordion-footer__version-2,
.accordion-footer__version-3,
.accordion-footer__version-4 {
    color: #C2140A;
}
.accordion-footer__status-2:hover,
.accordion-footer__status-3:hover,
.accordion-footer__status-4:hover {
    color: #E50C00;
}
.accordion-footer__status-3,
.accordion-footer__version-3,
.accordion-footer__status-4,
.accordion-footer__version-4 {
    font-size: 14px;
}
.accordion-footer__status-3,
.accordion-footer__status-4 {
    font-weight: bold;
}
.accordion-footer__status:hover {
    text-decoration: underline;
}
.accordion-footer__version, .accordion-footer__status {
    cursor: pointer;
}
.text-white {
    color: white;
}
</style>
