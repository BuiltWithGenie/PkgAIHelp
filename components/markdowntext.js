Vue.component("markdowntext", {
    template: `
        <div style="position: relative;">
            <div style="padding-right:30px">
                <md-block :key="contentKey">{{ text }}</md-block>
            </div>
            <button style="position: absolute; top: 0; right: 0; background: none; border: none; cursor: pointer;" @click="copyToClipboard(text)">
                <q-icon name="content_copy" color="white" />
            </button>
        </div>
    `,
    props: {
        text: String
    },
    computed: {
        randomKey() {
            return Math.random().toString(36).substring(2, 15);
        },
    contentKey() {
        return this.text.split('').reduce((a, b) => {
            a = ((a << 5) - a) + b.charCodeAt(0);
            return a&a;
        }, 0);
    }
    },
    methods: {
        copyToClipboard(str) {
            const el = document.createElement('textarea');
            el.value = str;
            el.setAttribute('readonly', '');
            el.style.position = 'absolute';
            el.style.left = '-9999px';
            document.body.appendChild(el);
            el.select();
            document.execCommand('copy');
            document.body.removeChild(el);
        }
    }
});
