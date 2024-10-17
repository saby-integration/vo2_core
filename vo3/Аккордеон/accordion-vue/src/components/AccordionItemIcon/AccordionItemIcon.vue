<template>
    <img
        :src="calculatedIcon"
        class="icon"
    />
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
        calculatedIcon() {
            return iconsLib[this.icon]
        }
    }
}
</script>

<style>
.icon {
    height: 20px;
    width: 20px;
}
</style>