const accordionItems = {}

export default function (arr = []) {
    for (const item of arr) {
        if (item['parent@'] || item.level === 1) {
            accordionItems[item.id] = [item]
        }
    }
    for (const item of arr) {
        if (item['parent@'] || item.level === 1) {
            continue
        }
        const itemParentId = item.parent
        accordionItems[itemParentId].push(item)
    }
    return Object
        .values(accordionItems)
        .reduce((resultArr, items) => {
            resultArr.push(...items)
            return resultArr
        }, [])
}
