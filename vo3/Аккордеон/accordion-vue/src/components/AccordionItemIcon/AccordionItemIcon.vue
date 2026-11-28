<template>
  <div>
    <div :class="iconClass" v-html="calculatedIcon"></div>
  </div >
</template>

<script>
import iconsLib from "./iconsLib";

export default {
    name: "AccordionItemIcon",
    props: {
       icon: {
           required: true,
           type: String
       }
    },
    computed: {
        iconClass() {
            return window.accordion?.theme === "dark"
                ? "icon-dark"
                : "icon";
        },
        calculatedIcon() {
            return atob(iconsLib[this.icon].split(',')[1]);
        }
    }
}
</script>

<style>
.icon {
    height: 20px;
    width: 20px;
}
.icon-dark {
  height: 20px;
  width: 20px;
}
.icon-dark svg path {
  fill: white;
}
</style>
