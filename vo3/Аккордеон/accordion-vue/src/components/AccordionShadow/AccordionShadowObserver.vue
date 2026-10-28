<template>
    <div ref="shadow"></div>
</template>

<script>
import 'intersection-observer'

export default {
    name: "AccordionShadowObserver",
    emits: ['visible'],
    props: {
        position: String
    },
    mounted() {
        const observer = new IntersectionObserver(entries => {
            this.$emit('visible', {
                visible: entries[0].isIntersecting,
                position: this.position
            })
        })
        observer.observe(this.$refs.shadow)
    }
}
</script>