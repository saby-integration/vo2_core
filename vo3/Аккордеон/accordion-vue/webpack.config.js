const HTMLInlineScriptWebpackPlugin = require('html-inline-script-webpack-plugin')
const HTMLWebpackPlugin = require('html-webpack-plugin')
const path = require('path')
const {VueLoaderPlugin} = require('vue-loader')

const isProd = process.env.NODE_ENV === 'production'
const isDev = !isProd

function getPlugins() {
    const plugins = [
        new VueLoaderPlugin(),
        new HTMLWebpackPlugin({
            template: './public/index.html',
            minify: {
                removeComments: true,
                collapseWhitespace: true
            },
            inject: 'body'
        })
    ]

    if (isProd) {
        plugins.push(new HTMLInlineScriptWebpackPlugin())
    }

    return plugins
}

const config = {
    mode: 'development',
    entry: ['@babel/polyfill', './src/index.js'],
    output: {
        path: path.resolve(__dirname, 'dist'),
        filename: 'bundle.js',
        environment: {
            arrowFunction: false,
            bigIntLiteral: false,
            const: false,
            destructuring: false,
            dynamicImport: false,
            forOf: false,
            module: false
        },
        clean: true
    },
    devtool: isDev ? 'source-map' : false,
    module: {
        rules: [
            {
                test: /\.css$/,
                use: [
                    'style-loader',
                    'css-loader'
                ]
            },
            {
                test: /\.vue$/,
                loader: 'vue-loader'
            },
            {
                test: /\.js$/,
                use: 'babel-loader',
                exclude: /node_modules/
            }
        ]
    },
    devServer: {
        port: 3001,
        open: true
    },
    resolve: {
        extensions: [
            '.js',
            '.vue'
        ]
    },
    plugins: getPlugins()
}

module.exports = config
