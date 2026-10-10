<template>
    <div
        class="accordion__shadow"
        :class="`accordion__shadow-${position}`"
        v-if="visibility"
    ></div>
</template>

<script>
export default {
    name: "AccordionShadow",
    props: {
        position: String,
        visibility: {
            type: Boolean,
            default: false
        }
    }
}
</script>

<style>
.accordion__shadow {
    height: 8px;
    position: absolute;
    left: 0;
    right: 0;
    z-index: 29;
}
.accordion__shadow-top {
    top: 0;
    background: linear-gradient(to bottom,rgba(0, 0, 0, 0.15),rgba(0, 0, 0, 0));
}
.accordion__shadow-bottom {
    bottom: 0;
    background: linear-gradient(to top,rgba(0, 0, 0, 0.15),rgba(0, 0, 0, 0));
}
</style>
