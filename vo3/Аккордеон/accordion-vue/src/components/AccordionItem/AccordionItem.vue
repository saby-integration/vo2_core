<template>
    <div
        class="tree-item"
        :class="[
            isSelectedItem && 'tree-item__selected',
            isChildren && 'tree-item__children'
        ]"
        :style="{paddingLeft: levelPadding ? `${levelPadding}px` : null}"
        @click="itemClick"
    >
    <!-- Подписка на одно и то же событие необходима на всех узлах из за бага в webkit на linux-->
    <!-- событие о клике, по какой то причине не всплывает вверх-->
        <div
            class="tree-item__content"
            @click.stop="itemClick"
        >
            <div
                class="tree-item__wrapper"
                @click.stop="itemClick"
            >
                <accordion-item-icon
                    v-if="item.icon"
                    :icon="item.icon"
                    class="tree-item__icon"
                />
                <div
                    class="tree-item__title"
                    :title="item.title"
                    @click.stop="itemClick"
                >{{item.title}}</div>
            </div>
            <accordion-item-expander
                class="tree-item__expander"
                v-if="isParent"
                :is-expended="isExpended"
                @click="expanderClickHandler"
            />
        </div>
    </div>
</template>

<script>
import AccordionItemExpander from "../AccordionItemExpander/AccordionItemExpander";
import AccordionItemIcon from "../AccordionItemIcon/AccordionItemIcon";

export default {
    name: "AccordionItem",
    components: {AccordionItemIcon, AccordionItemExpander},
    props: {
        item: Object,
        selectedItem: String,
        expandedItemsId: Array
    },
    emits: ['toggleTree', 'itemSelect'],
    methods: {
        itemClick() {
            // если action = false, то просто разворачиваем узел
            if (!this.item.action) {
                this.expanderClickHandler()
                return
            }
            // Происходит при нажатии на элемент
            this.$emit('itemSelect', this.item.id)
        },
        expanderClickHandler() {
            // Происходит при нажатии на кнопку разворота узла
            this.$emit('toggleTree', this.item.id)
        }
    },
    computed: {
        isSelectedItem() {
            return this.selectedItem === this.item.id
        },
        levelPadding() {
            return (this.item.level - 1) * 32
        },
        isChildren() {
            return this.item.level > 1
        },
        isParent() {
            return !!this.item['parent@']
        },
        isExpended() {
            return !!this.expandedItemsId.find(id => id === this.item.id)
        }
    }
}
</script>

<style>
.tree-item {
    margin-bottom: 2px;
    cursor: pointer;
    align-items: center;
    -webkit-align-items: center;
    position: relative;
    border-radius: 8px;
    user-select: none;
    -webkit-user-select: none;
    height: 46px;
}
.tree-item:hover {
    background: #f3f4f8!important;
}
.tree-item__children {
    height: 31px;
}
.tree-item__content {
    display: flex;
    display: -webkit-flex;
    align-items: center;
    -webkit-align-items: center;
    justify-content: space-between;
    -webkit-justify-content: space-between;
    height: 100%;
}
.tree-item__wrapper {
    display: flex;
    display: -webkit-flex;
    align-items: center;
    -webkit-align-items: center;
    overflow: hidden;
    padding: 0 0 0 12px;
    height: 100%;
}
.tree-item__title {
    font-size: 18px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}
.tree-item__children .tree-item__title {
    font-size: 16px!important;
}
.tree-item__children .tree-item__wrapper {
    padding: 0 12px 0 12px;
}
.tree-item__expander {
    display: none;
}
.tree-item:hover .tree-item__expander,
.tree-item.tree-item__selected .tree-item__expander
{
    display: flex;
    display: -webkit-flex;
}
.tree-item__icon {
    margin: 0 12px 0 0;
}
.tree-item.tree-item__selected {
    background: #f3f4f8!important;
}
.tree-item__selected.tree-item:before {
    content: '';
    position: absolute;
    top: 50%;
    transform: translateY(-50%);
    -webkit-transform: translateY(-50%);
    left: 0;
    right: 0;
    bottom: 0;
    height: 22px;
    width: 3px;
    background: #0c94ff;
}
</style>
