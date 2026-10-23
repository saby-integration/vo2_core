<template>
    <div
        class="accordion"
    >
        <accordion-header :appName="appName"/>
        <div class="accordion__wrapper">
            <accordion-shadow
                position="top"
                :visibility="shadowVisible.top"
            />
            <div class="accordion__scroll">
                <accordion-shadow-observer
                    position="top"
                    @visible="shadowObserverVisibleHandler"
                />
                <div class="accordion__tree">
                    <accordion-item
                        v-for="item in calculatedAccordionItems"
                        :key="item.id"
                        :item="item"
                        :selected-item="selectedItem"
                        :expanded-items-id="expandedItemsId"
                        @toggleTree="toggleFolder"
                        @itemSelect="selectItemHandler"
                    />
                </div>
                <accordion-shadow-observer
                    position="bottom"
                    @visible="shadowObserverVisibleHandler"
                />
            </div>
            <accordion-shadow
                position="bottom"
                :visibility="shadowVisible.bottom"
            />
        </div>
        <accordion-footer
          :product-version-status="productVersionStatus"
        />
    </div>
</template>

<script>
import AccordionShadowObserver from "../AccordionShadow/AccordionShadowObserver";
import AccordionFooter from "../AccordionFooter/AccordionFooter";
import AccordionHeader from "../AccordionHeader/AccordionHeader";
import AccordionShadow from "../AccordionShadow/AccordionShadow";
import AccordionItem from "../AccordionItem/AccordionItem";
import Connector from "../../core/Connector";
import {getVisibleAccordionItems} from "../utils";

export default {
    name: "Accordion",
    components: {
        AccordionShadowObserver,
        AccordionShadow,
        AccordionFooter,
        AccordionHeader,
        AccordionItem
    },
    data() {
        return {
            accordionItems: [],
            selectedItem: null,
            expandedItemsId: [],
            shadowVisible: {
                top: false,
                bottom: false
            },
            appName: 'SABY',
            productVersionStatus: {}
        }
    },
    beforeMount() {
        const accordionSettings = window.accordion
        this.appName = accordionSettings.appName || this.appName
        this.accordionItems = accordionSettings.accordion || []
        this.productVersionStatus = accordionSettings.productVersionStatus
        this.selectedItem = this.accordionItems.find(accItem => accItem.id === accordionSettings.selectedItem)

        this.initSelectedItem()

        window.updateFooter = footerData => {
          const [_, version, statusId] = Connector._decode(footerData)
          this.productVersionStatus = {
            clientVersionStatus: statusId,
            currentVersionNumber: version
          }
        }
    },
    computed: {
        // Расчитываем элементы которые должны быть отрисованы
        calculatedAccordionItems() {
            return getVisibleAccordionItems(this.accordionItems, this.expandedItemsId);
        }
    },
    methods: {
        // Если изначально выбран элемент n уровня, то раскрываем его родителя
        initSelectedItem() {
            if (this.selectedItem) {
                const selectedItem = this.accordionItems.find(accItem => accItem.id === this.selectedItem.id)
                const selectedItemParentId = selectedItem?.parent
                if (selectedItemParentId) {
                    this.toggleFolder(selectedItemParentId)
                }
            }
        },
        selectItemHandler(item) {
            this.selectedItem = item
            Connector.navigate(item.id)
        },
        toggleFolder(id) {
            const hasInExpendedItems = this.expandedItemsId.find(itemId => itemId === id)
            if (hasInExpendedItems) {
              this.expandedItemsId = this.expandedItemsId.filter(itemId => itemId !== id)
              return
            }
            this.expandedItemsId.push(id)
        },
        shadowObserverVisibleHandler({visible, position}) {
            this.shadowVisible[position] = !visible
        }
    }
}
</script>

<style>
.accordion {
    display: flex;
    display: -webkit-flex;
    width: 100%;
    height: 100%;
    flex-direction: column;
    -webkit-flex-direction: column;
    padding-top: 26px;
}
.accordion__wrapper {
    height: 100%;
    position: relative;
    overflow-y: hidden;
}
.accordion__scroll {
    height: 100%;
    overflow-y: scroll;
}
.accordion__scroll::-webkit-scrollbar {
    display: none;
}
</style>
