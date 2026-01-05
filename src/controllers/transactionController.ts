import { Response } from "express";
import { AuthRequest } from "../middleware/auth";
import Transaction from "../models/Transaction";
import Category from "../models/Category";

export const addMoney = async (req: AuthRequest, res: Response) => {
    try {
        const { categoryId, amount } = req.body;

        const category = await Category.findOne({ _id: categoryId, userId: req.user });
        if (!category) return res.status(404).json({ msg: "Category not found" });

        category.balance += amount;
        await category.save();

        const tx = await Transaction.create({
            userId: req.user,
            categoryId,
            amount,
            type: "ADD"
        });

        res.json({ category, transaction: tx });
    } catch (err) {
        res.status(500).json({ error: "Server error" });
    }
};

export const subtractMoney = async (req: AuthRequest, res: Response) => {
    try {
        const { categoryId, amount } = req.body;

        const category = await Category.findOne({ _id: categoryId, userId: req.user });
        if (!category) return res.status(404).json({ msg: "Category not found" });

        category.balance -= amount;
        await category.save();

        const tx = await Transaction.create({
            userId: req.user,
            categoryId,
            amount,
            type: "SUBTRACT"
        });

        res.json({ category, transaction: tx });
    } catch (err) {
        res.status(500).json({ error: "Server error" });
    }
};

export const getTransactions = async (req: AuthRequest, res: Response) => {
    try {
        const tx = await Transaction.find({
            userId: req.user,
            categoryId: req.params.categoryId
        });

        res.json(tx);
    } catch (err) {
        res.status(500).json({ error: "Server error" });
    }
};
