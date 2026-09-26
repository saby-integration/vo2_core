/**
 * Строит массив видимых элементов аккордеона
 * @param {Array} accordionItems - все элементы
 * @param {Array} expandedItemsId - ID раскрытых родителей
 * @returns {Array} плоский массив видимых элементов в правильном порядке
 */
export default function getVisibleAccordionItems(
    accordionItems,
    expandedItemsId,
) {
    // Удаляем дубликаты (дубликаты приходят с VO2)
    accordionItems = deleteDublicateIds(accordionItems);

    // Объект { [parentId]: [children][] }
    const accordionGroupedByParents = groupByParent(accordionItems)

    // Находим корневые элементы (уровень 1)
    const rootItems = accordionItems.filter(item => item.level === 1);

    // Рекурсивная функция для сбора видимых элементов
    function collectVisibleItems(items, result = []) {
        for (let i = 0; i < items.length; i++) {
            const item = items[i];
            // Добавляем текущий элемент
            result.push(item);

            // Проверяем, есть ли у элемента дети и раскрыт ли он
            const hasChildren = accordionGroupedByParents[item.id]?.length > 0;
            const isExpanded = expandedItemsId.indexOf(item.id) !== -1;

            // Если есть дети и элемент раскрыт - рекурсивно добавляем их
            if (hasChildren && isExpanded) {
                const children = accordionGroupedByParents[item.id];
                collectVisibleItems(children, result);
            }
        }
        return result;
    }

    // Запускаем сбор с корневых элементов
    return collectVisibleItems(rootItems);
}

/**
 * Группировка элементов по родителям
 * @param arr
 * @returns { [parentId]: [children][] }
 */
function groupByParent(arr = []) {
    const groupedElements = {}
    // Формируется объект с родителями
    for (let i = 0; i < arr.length; i++) {
        if (arr[i]['parent@']) {
            groupedElements[arr[i].id] = []
        }
    }
    // Формируются дочерние элементы родителей
    for (let j = 0; j < arr.length; j++) {
        if (groupedElements[arr[j].parent]) {
            groupedElements[arr[j].parent].push(arr[j]);
        }
    }
    return groupedElements
}

/**
 * Удаляет элементы с дублирующимися id
 * @param {Array} accordionItems - все элементы
 * @returns {Array} Массив элементов без дубликатов
 */
function deleteDublicateIds(accordionItems) {
      const result = accordionItems.filter((value, index, self) =>
            index === self.findIndex((element) => (
              element.id === value.id
            ))
    )
    return result;
}