<template>
    <div
        class="tree-item"
        :class="[
            isSelectedItem && 'tree-item__selected',
            isChildren && 'tree-item__children',
            isDarkTheme && 'tree-item_dark'
        ]"
        :style="{paddingLeft: levelPadding ? `${levelPadding}px` : null}"
        @click="itemClick"
    >
    <!-- Подписка на одно и то же событие необходима на всех узлах из за бага в webkit на linux-->
    <!-- событие о клике, по какой то причине не всплывает вверх-->
        <div
            class="tree-item__content-wrapper"
            @click.stop="itemClick"
        >
          <div class="tree-item__content" :style="{ width: item.count ? null : `100%` }">
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
                  :class="titleClass"
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
            <div class="tree-item__count">
              <div title="Просроченные" class="tree-item__count-overdue" v-if="item.count && item.count.overdue">{{item.count.overdue}}</div>
              <div title="Текущие" class="tree-item__count-current" v-if="item.count && item.count.current">{{item.count.current}}</div>
            </div>
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
        selectedItem: Object,
        expandedItemsId: Array
    },
    emits: ['toggleTree', 'itemSelect'],
    methods: {
        itemClick() {
            // если action = false, то просто разворачиваем узел
            if (!this.hasAction) {
              this.expanderClickHandler()
              return
            }
            if (this.item?.['parent@']) {
              this.expanderClickHandler()
            }
            // Происходит при нажатии на элемент
            this.$emit('itemSelect', this.item)
        },
        expanderClickHandler() {
            // Происходит при нажатии на кнопку разворота узла
            this.$emit('toggleTree', this.item.id)
        }
    },
    computed: {
        isSelectedItem() {
            try {
              if (this.isParent && this.hasAction && !this.isParentOpen) {
                return this.selectedItem?.parent === this.item.id || this.selectedItem?.id === this.item.id
              }
              if (this.isParentOpen) {
                return this.selectedItem?.id === this.item.id
              }
              if (!this.isParent && !this.isChildren) {
                return this.selectedItem?.id === this.item.id
              }
              return this.item.id === this.selectedItem?.parent
            } catch (e) {
              return false
            }
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
        },
        hasAction() {
          return this.item.action
        },
        isParentOpen() {
            if (this.isParent) {
              return this.expandedItemsId.includes(this.item.id)
            }
            return this.expandedItemsId.includes(this.item.parent)
        },
        isDarkTheme() {
            return window.accordion?.theme === "dark";
        },
        titleClass() {
            return this.isDarkTheme
              ? "tree-item__title text-white"
              : "tree-item__title";
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
.tree-item_dark:hover {
    background: #ffffff1f!important;
}
.tree-item__children {
    height: 31px;
}
.tree-item__content-wrapper {
    display: flex;
    display: -webkit-flex;
    align-items: center;
    -webkit-align-items: center;
    justify-content: space-between;
    -webkit-justify-content: space-between;
    height: 100%;
}
.tree-item__content {
  display: flex;
  display: -webkit-flex;
  align-items: center;
  -webkit-align-items: center;
  justify-content: space-between;
  -webkit-justify-content: space-between;
  overflow: hidden;
  text-overflow: ellipsis;
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
    align-items: center;
    text-overflow: ellipsis;
}
.text-white {
    color: white;
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
.tree-item__count {
  display: flex;
  display: -webkit-flex;
  padding-right: 5px;
  height: 13px;
}
.tree-item__count-overdue {
  color: #CC3D00;
  padding-right: 7px;
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
.tree-item_dark.tree-item__selected {
    background: rgba(255, 255, 255, 0.12)!important;
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
