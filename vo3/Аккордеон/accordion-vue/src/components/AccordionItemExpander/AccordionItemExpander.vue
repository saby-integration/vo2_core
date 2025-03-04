<template>
    <div
        class="expander__wrapper"
        :class="[isExpended && 'expander__expended']"
        @click.stop="clickHandler"
    >
        <svg
            width="12"
            height="7"
            viewBox="0 0 12 7"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
            class="expander"
        >
            <g clip-path="url(#clip0_203_1049)">
                <path fill-rule="evenodd" clip-rule="evenodd" d="M0.331055 1.74329L1.66898 0.256706L6.00002 4.15464L10.3311 0.256706L11.669 1.74329L6.00002 6.84536L0.331055 1.74329Z" class="expander_svg"/>
            </g>
            <defs>
                <clipPath id="clip0_203_1049">
                    <rect width="12" height="7" fill="white"/>
                </clipPath>
            </defs>
        </svg>
    </div>
</template>

<script>
export default {
    name: "AccordionItemExpander",
    emits: ['click'],
    props: {
        isExpended: Boolean
    },
    methods: {
        clickHandler() {
            this.$emit('click')
        }
    }
}
</script>

<style>
.expander {
    transform: rotate(-90deg);
    -webkit-transform: rotate(-90deg);
}
.expander__wrapper {
    padding: 0 12px;
    height: 100%;
    justify-content: flex-end;
    -webkit-justify-content: flex-end;
    align-items: center;
    -webkit-align-items: center;
}
.expander__expended {
    display: flex!important;
}
.expander__expended > svg {
    transform: rotate(0);
    -webkit-transform: rotate(0);
}
.expander_svg {
    fill: #8991a9;
}
.expander__wrapper:hover .expander_svg {
    fill: #313e78;
}
</style>
