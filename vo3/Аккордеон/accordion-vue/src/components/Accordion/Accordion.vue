<template>
    <div
        class="accordion"
        :style="{paddingTop: marginTop}"
    >
        <accordion-header/>
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
            :margin="marginTop"
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
import {sortAndGroupByProperty} from "../utils";

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
            accordionItems: null,
            selectedItem: null,
            expandedItemsId: [],
            marginTop: null,
            shadowVisible: {
                top: false,
                bottom: false
            }
        }
    },
    beforeMount() {
        const accordionSettings = window.accordion
        this.accordionItems = accordionSettings.accordion || []
        this.selectedItem = accordionSettings.selectedItem
        this.marginTop = accordionSettings.marginTop
        this.initSelectedItem()
    },
    computed: {
        // Расчитываем элементы которые должны быть отрисованы
        calculatedAccordionItems() {
            const accordionItems = sortAndGroupByProperty(this.accordionItems)
            return accordionItems.reduce((renderItems, accItem) => {
                // Если это элемент первого уровня в любом случае добавляем его в списко на редер
                if (accItem.level === 1) {
                    renderItems.push(accItem)
                }
                const hasInExpendedParent = this.expandedItemsId.find(itemId => itemId === accItem.parent)
                // Если родитель раскрыт, то рендерим ребенка
                if (hasInExpendedParent) {
                    renderItems.push(accItem)
                }
                return renderItems
            }, [])
        }
    },
    methods: {
        // Если изначально выбран элемент n уровня, то раскрываем его родителя
        initSelectedItem() {
            if (this.selectedItem) {
                const selectedItem = this.accordionItems.find(accItem => accItem.id === this.selectedItem)
                const selectedItemParentId = selectedItem?.parent
                if (selectedItemParentId) {
                    this.toggleFolder(selectedItemParentId)
                }
            }
        },
        selectItemHandler(id) {
            this.selectedItem = id
            Connector.navigate(id)
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
