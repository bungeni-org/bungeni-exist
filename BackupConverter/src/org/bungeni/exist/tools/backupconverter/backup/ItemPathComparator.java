package org.bungeni.exist.tools.backupconverter.backup;


import java.util.Comparator;

/**
 * Comparator for ordering Items A-Z by their Path
 *
 * @author Adam Retter <adam.retter@googlemail.com>
 * @version 1.0
 */
public class ItemPathComparator implements Comparator<Item>
{
    /**
     * Compares two Item Paths A-Z
     *
     * @see java.util.Comparator#compare(java.lang.Object, java.lang.Object)
     */
    @Override
    public int compare(Item item1, Item item2)
    {
        return item1.getPath().compareTo(item2.getPath());
    }
}
